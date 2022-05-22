// This file is heavily inspired by https://github.com/enisdenjo/graphql-ws.

import Combine
import GraphQL
import Foundation
import os

/// A GraphQL client that lets you send queries over WebSocket protocol.
///
/// - NOTE: The client assumes that you'll manually establish the socket connection
///         and that it may send requests.
@available(macOS 12, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class GraphQLWebSocket: NSObject, URLSessionWebSocketDelegate {
    
    /// Configuration of the behaviour of the client.
    private var config: GraphQLWebSocket.Config
    
    /// Session that should be used to create a WebSocket task.
    private var session: URLSession
    
    /// Connection parameters for the task.
    private var request: URLRequest
    
    /// Shared encoder used to encode the request.
    private var encoder: JSONEncoder = JSONEncoder()
    
    /// Shared decoder used for decoding responses.
    private var decoder: JSONDecoder = JSONDecoder()
    
    // MARK: - State
    
    /// Transport WebSocket connection with the server.
    private var socket: URLSessionWebSocketTask?
    
    /// Holds information about the connection health and what the client is doing about it.
    private var health: Health = Health.notconnected
    
    private enum Health: Equatable {

        /// Connection is healthy and client can communicate with the server.
        case acknowledged

        /// Connection with the server hasn't been established yet.
        case notconnected
        
        /// A connetion has been established with the server, but the server hasn't acknowledged the connection yet.
        case connecting

        /// Server is unreachable and client is trying to reconnect.
        case reconnecting(retry: Int)
    
        /// The client has been disposed and we shouldn't attempt to make any new connections.
        case disposed
    }
    
    /// Queue of messages that should be sent to the server.
    ///
    /// - NOTE: The 0-th message should be sent first.
    private var queue = [ClientMessage]()
    
    public enum Event {
        /// Client started connecting.
        case connecting
        
        /// WebSocket has opened.
        case opened(socket: URLSessionWebSocketTask)
        
        /// Open WebSocket connection has been acknowledged
        case connected(payload: [String: AnyCodable]?)
        
        /// Ping message has been received or sent.
        ///
        /// - parameter received: Tells whether the ping was received from the server. If `false` the client sent the ping.
        case ping(received: Bool, payload: [String: AnyCodable]?)
        
        /// Pong message has been received or sent.
        ///
        /// - parameter received: Tells whether the pong was received from the server. If `false` the client sent the event.
        case pong(received: Bool, payload: [String: AnyCodable]?)
        
        /// A message from the server has been received.
        case message(ServerMessage)
        
        /// WebSocket connection has closed.
        case closed
        
        /// WebSocket connection had an error or client had an internal error.
        case error(Error)
    }
    
    /// The central subject that publishes all events to the pipelines.
    private var emitter = PassthroughSubject<Event, Never>()
    
    /// A timer reference responsible for checking that the server has ACK the connection in timely manner.
    /// https://stackoverflow.com/a/26808801/2946444
    weak private var ackTimer: Timer?
    
    /// A timer reference responsible for keeping the connection alive by sending pings.
    /// https://stackoverflow.com/a/26808801/2946444
    weak private var pingTimer: Timer?
    
    /// A timer reference responsible for retrying to reconnect after a given period of time elapses.
    /// https://stackoverflow.com/a/26808801/2946444
    weak private var reconnectTimer: Timer?
    
    /// Timer that starts the disconnect procedure when there are no more listeners.
    weak private var lazyCloseTimer: Timer?
    
    /// Timer that fires off when the server hasn't replyed with PONG for too long.
    weak private var connectionDroppedTimer: Timer?
    
    /// Holds references to pipelines created by subscriptions. Each pipeline is identified by the
    /// query id of the subscription that created a pipeline.
    ///
    /// - NOTE: We also use pipelines to tell how many ongoing connections the client is managing.
    private var pipelines = [String: AnyCancellable]()
    
    // MARK: - Initializer
    
    /// Creates a new GraphQL WebSocket client from the given connection.
    public init(
        request: URLRequest,
        config: GraphQLWebSocket.Config = Config(),
        session: URLSession = URLSession.shared
    ) {
        self.session = session
        self.request = request
        self.config = config
        
        super.init()
        
        if self.config.behaviour == .eager {
            self.connect()
        }
    }

    // MARK: - Internals
    
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        self.config.logger.debug("Socket opened!")
        
        // Immediatelly notify all listeners about the health change.
        self.emitter.send(Event.opened(socket: webSocketTask))
        self.health = .connecting
        
        // Once the connection opens, we start recursively processing server messages.
        if self.config.connectionAckTimeout > 0 {
            self.config.logger.debug("Scheduling connection acknowledge timeout timer...")
            
            self.ackTimer = Timer.scheduledTimer(
                withTimeInterval: TimeInterval(self.config.connectionAckTimeout),
                repeats: false,
                block: { _ in
                    let message = Data("Connection acknowledgement timeout".utf8)
                    self.socket?.cancel(with: .goingAway, reason: message)
                })
        }
        
        self.tick()
        self.send(message: ClientMessage.initalise(payload: self.config.connectionParams))
        self.flushQueue()
    }
    
    
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        self.config.logger.debug("Connection with the server closed!")
        
        // The server shouldn't reconnect, we tell all listeners to stop listening.
        guard shouldRetryToConnect(code: closeCode) else {
            self.emitter.send(Event.closed)
            
            self.pingTimer = nil
            self.lazyCloseTimer = nil
            self.ackTimer = nil
            self.reconnectTimer = nil
            self.connectionDroppedTimer = nil
            
            self.config.logger.debug("Terminated connection and cleared timers!")
            
            return
        }
        
        var retry: Int = 0
        if case .reconnecting(let attempt) = health {
            retry = attempt
        }
        
        self.config.logger.debug("Reconnecting to the server...")
        
        self.reconnectTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(self.config.retryWait(retry)),
            repeats: false,
            block: { [weak self] _ in
                // A reconnect should always happen if the client connects eagerly,
                // even if we have no current listeners.
                guard let self = self, !self.pipelines.isEmpty, self.config.behaviour != .eager else {
                    return
                }
                
                self.config.logger.debug("Reconnection in progress...")
                
                self.connect()
            })
    }
    
    /// Creates a new socket connection and kicks-off the communication with the server.
    private func connect() {
        self.config.logger.debug("Started connecting to the server...")
        
        // Prevent the timer from closing the socket because
        // a new pipeline was created.
        self.lazyCloseTimer?.invalidate()
        
        switch self.health {
        case .acknowledged:
            self.config.logger.debug("Connection already established, skipping!")
            return
        default:
            // https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md#communication
            var request = self.request
            request.setValue("graphql-transport-ws", forHTTPHeaderField: "Sec-WebSocket-Protocol")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            
            let socket = self.session.webSocketTask(with: request)
            socket.delegate = self
            self.socket = socket
            self.config.logger.debug("Socket created!")
            
            socket.resume()
            self.config.logger.debug("Socket task resumed!")
        }
    }
    
    /// Prepares the client to disconnect if necessary once the connecction has dropped.
    private func disconnect() {
        guard case .lazy(let timeout) = self.config.behaviour, self.health == .acknowledged else {
            return
        }
        
        self.config.logger.debug("Disconnecting from the server...")
        
        self.lazyCloseTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(timeout),
            repeats: false,
            block: { [weak self] _ in
                guard let self = self, self.pipelines.isEmpty, self.socket?.state == .running else {
                    return
                }
                
                self.config.logger.debug("Closing the connection!")
                
                let message = Data("Normal Closure".utf8)
                self.socket?.cancel(with: URLSessionWebSocketTask.CloseCode.normalClosure, reason: message)
            })
    }
    
    /// Decodes the next socket message received from the server and forwards it to the handler.
    private func receive(handler: @escaping (Result<ServerMessage, Error>) -> Void) {
        self.config.logger.debug("Waiting for new message from the server...")
        
        self.socket?.receive { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.config.logger.debug("Received a new message from the server!")
            
            var message: ServerMessage? = nil
            switch result {
            case .success(.string(let str)):
                self.config.logger.debug("Got 'string' message from the server.")
                message = try? self.decoder.decode(ServerMessage.self, from: Data(str.utf8))
            case .success(.data(let data)):
                self.config.logger.debug("Got 'data' message from the server.")
                message = try? self.decoder.decode(ServerMessage.self, from: data)
            case .failure(let error):
                self.config.logger.debug("Got invalid response from the server ('\(error.localizedDescription)').")
//                handler(.failure(error))
//                return
            @unknown default:
                fatalError()
            }
            
            if let message = message {
                handler(.success(message))
            }
        }
    }
    
    /// Sends a message using the websocket transport.
    private func send(message: ClientMessage) {
        guard let socket = self.socket, socket.state == .running else {
            self.config.logger.debug("Socket not ready, queueing message \(message.description)...")
            self.queue.append(message)
            return
        }
        
        let data = try! self.encoder.encode(message)
        switch (self.health, message) {
        case (.acknowledged, _), (_, .initialise), (_, .ping), (_, .pong):
            // We can send any message when the connection has been ACK and meta messages when the server hasn't ACK the connection yet.
            self.send(data: data)
            self.config.logger.debug("\(message.description) sent to the server!")
            
        default:
            self.config.logger.debug("Transport not ready, queueing message \(message.description)...")
            self.queue.append(message)
        }
    }
    
    /// Sends data to the server via open socket connection.
    ///
    /// - NOTE: This function assumes that the connection is open and healthy.
    private func send(data: Data) {
        self.socket?.send(.data(data)) { [weak self] err in
            if let self = self, let err = err {
                self.config.logger.debug("Message delivery failed (\(err.localizedDescription))...")
                self.emitter.send(Event.error(err))
            }
        }
    }
    
    /// Empties the message queue if possible.
    private func flushQueue() {
        guard self.socket?.state == .running else {
            return
        }
        
        // We take the count of messages in the queue before
        // flushing it to make sure we only process each message once.
        // Messages can reinsert themself in the queue if they are not yet ready.
        var numberOfOutstandingMessages = self.queue.count
        self.config.logger.debug("Flushing \(numberOfOutstandingMessages) messages from queue...")
        
        while numberOfOutstandingMessages > 0 {
            self.send(message: self.queue.removeFirst())
            numberOfOutstandingMessages -= 1
        }
        
        self.config.logger.debug("Queue flushed!")
    }
    
    /// Sends a ping request and starts the response timeout.
    private func ping() {
        self.send(message: ClientMessage.ping())
        self.emitter.send(Event.ping(received: false, payload: nil))
        self.config.logger.debug("Emitted a PING message!")
        
        // We schedule a response timeout that has to be cleared
        // in a timely manner by receiveing a new message from the server.
        self.connectionDroppedTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(3 * self.config.keepAlive),
            repeats: true,
            block: { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.socket?.cancel(
                    with: .noStatusReceived,
                    reason: Data("No PONG reply".utf8)
                )
            })
    }
    
    /// Processes a management message from the server and forwards data message
    /// to event listeners.
    private func tick() {
        self.receive { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.connectionDroppedTimer?.invalidate()
            self.config.logger.debug("Processing server message...")
            
            switch (self.health, result) {
                
            case (.connecting,.success(.acknowledge(let msg))):
                self.config.logger.debug("Received ACK message!")
                
                self.emitter.send(Event.message(.acknowledge(msg)))
                self.emitter.send(Event.connected(payload: msg.payload))
                
                self.health = .acknowledged
                self.ackTimer?.invalidate()
                self.flushQueue()
                
                guard self.config.keepAlive > 0 else {
                    break
                }
                
                self.config.logger.debug("Scheduling a ping timer.")
                self.pingTimer = Timer.scheduledTimer(
                    withTimeInterval: TimeInterval(self.config.keepAlive),
                    repeats: true,
                    block: { [weak self] _ in
                        guard let self = self else { return }
                        self.ping()
                    })
                
                
                break
            
            case (.connecting, .success(_)):
                self.config.logger.debug("Received an invalid first message. Closing socket!")
                
                // If the previous statement didn't catch this message, we got an invalid
                // message before acknowledgement.
                let message = Data("First message has to be ACK".utf8)
                self.socket?.cancel(with: URLSessionWebSocketTask.CloseCode.policyViolation, reason: message)
                return
                
            case (_, .success(.ping(let msg))):
                self.config.logger.debug("Received a PING request...")
                
                self.emitter.send(Event.message(.ping(msg)))
                
                self.emitter.send(Event.ping(received: true, payload: nil))
                self.send(message: ClientMessage.pong(payload: msg.payload))
                self.emitter.send(Event.pong(received: false, payload: msg.payload))
                
                self.config.logger.debug("Sent a PONG response!")
                
                break
                
            case (_, .success(.pong(let msg))):
                self.config.logger.debug("Processing a PONG message...")
                
                self.emitter.send(Event.message(.pong(msg)))
                self.emitter.send(Event.pong(received: true, payload: msg.payload))
                
                break
            
            case (_, .success(let msg)):
                self.emitter.send(Event.message(msg))
                
            case (_, .failure(let err)):
                // As soon as the reading of the message fails, emit an error and stop
                // processing new messages.
                self.emitter.send(Event.error(err))
                self.socket?.cancel(with: .invalidFramePayloadData, reason: Data("Bad response".utf8))
                return
            }
            
            // Recursively process the next event.
            self.tick()
        }
    }
    
    // MARK: - Calculations
    
    /// Checks the state of the client and tells whether the client should try reconnecting to the
    /// server given the received event.
    private func shouldRetryToConnect(code: URLSessionWebSocketTask.CloseCode) -> Bool {
        
        // Client was disposed and we shouldn't retry to reconnect.
        if case .disposed = self.health {
            return false
        }
    
        let isTerminatingCloseCode = [
            CloseCode.internalServerError.rawValue,
            CloseCode.internalClientError.rawValue,
            CloseCode.badRequest.rawValue,
            CloseCode.badResponse.rawValue,
            CloseCode.unauthorized.rawValue,
            
            CloseCode.subprotocolNotAcceptable.rawValue,
            
            CloseCode.subscriberAlreadyExists.rawValue,
            CloseCode.tooManyInitialisationRequests.rawValue
        ]
            .contains(code.rawValue)
        
        if Self.isFatalInternalCloseCode(code: code.rawValue) || isTerminatingCloseCode {
            return false
        }
        
        // Check that all locks have been released when receiving a regular closure.
        if (code == URLSessionWebSocketTask.CloseCode.normalClosure) {
            return self.pipelines.count > 0
        }
        
        if case let .reconnecting(retries) = self.health, retries >= self.config.retryAttempts {
            return false
        }
        
        return true
    }
    
    /// Tells whether the provided close code is unrecoverable by the client.
    private static func isFatalInternalCloseCode(code: Int) -> Bool {
        let recoverable = [
            1000, // Normal Closure is not an erroneous close code
            1001, // Going Away
            1006, // Abnormal Closure
            1005, // No Status Received
            1012, // Service Restart
            1013, // Try Again Later
            1013, // Bad Gateway
        ]
        
        if recoverable.contains(code) {
            return false
        }
        return 1000 <= code && code <= 1999
    }
    
    // MARK: - Methods
    
    /// Returns a stream of events that get triggered when the client's state changes.
    public func onEvent() -> AnyPublisher<Event, Never> {
        self.emitter.share().eraseToAnyPublisher()
    }
    
    /// Creates a publisher that emits results received from the server
    /// of the provided query.
    ///
    /// - NOTE: The client sends the request to the server once a subscriber has
    ///         subscribed - not as soon as you call `subscribe` method.
    public func subscribe(_ args: ExecutionArgs) -> AnyPublisher<ExecutionResult, Error> {
        let id = UUID().uuidString
        
        // We create a new publisher that is bound to the pipeline
        // that watches server events and forwards them to the subscriber.
        // There's one pipeline for every subscription.
        let subject = PassthroughSubject<ExecutionResult, Error>()
        
        self.pipelines[id] = self.emitter
            .share()
            .compactMap({ state -> ServerMessage? in
                switch state {
                case .message(let message):
                    return message
                case .closed:
                    subject.send(completion: .finished)
                    return nil
                case .error:
                    return nil
                default:
                    return nil
                }
            })
            .filter({ message in
                switch message {
                case .next(let msg):
                    return msg.id == id
                case .complete(let msg):
                    return msg.id == id
                case .error(let msg):
                    return msg.id == id
                default:
                    return true
                }
            })
            .sink { message in
                switch message {
                case .next(let payload):
                    // NOTE: Payload may include execution errors alongside the
                    // data that don't result in stream termination.
                    subject.send(payload.payload)
                    
                case .error(let payload):
                    // NOTE: We send validation errors returned as standalone
                    // messages as terminating events down the stream
                    // since we don't expect to receive any other events.
                    subject.send(completion: .failure(payload.payload))
                    
                case .complete:
                    // NOTE: We only forward the completion event since the
                    // results pipeline handles the clearing of resources on its own.
                    subject.send(completion: .finished)
                    
                default:
                    ()
                }
            }
        
        let results = subject
            .handleEvents(receiveSubscription: { subscription in
                // User has started listening for events, we ask the server
                // to start sending results.
                self.connect()
                self.send(message: ClientMessage.subscribe(id: id, payload: args))
                
                self.config.logger.debug("Subscription \(id) initializing...")
            }, receiveCompletion: { completion in
                // Server has stopped sending requests, we just clear up the resources.
                self.pipelines.removeValue(forKey: id)
                self.config.logger.debug("Subscription \(id) completed!")
            }, receiveCancel: {
                // User has cancelled the subscription. We notify the server
                // to stop sending results and free memory allocated to processing the subscription.
                self.send(message: ClientMessage.complete(id: id))
                self.pipelines.removeValue(forKey: id)
                self.disconnect()
                self.config.logger.debug("Subscription \(id) cancelled!")
            })
            .eraseToAnyPublisher()
        
        return results
    }
    
}
