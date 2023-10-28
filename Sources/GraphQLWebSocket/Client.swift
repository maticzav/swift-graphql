// This file is heavily inspired by https://github.com/enisdenjo/graphql-ws.

import Combine
import GraphQL
import Foundation

/// A GraphQL client that lets you send queries over WebSocket protocol.
///
/// - NOTE: The client assumes that you'll manually establish the socket connection
///         and that it may send requests.
public class GraphQLWebSocket: WebSocketDelegate {
    
    /// Configuration of the behaviour of the client.
    private let config: GraphQLWebSocketConfiguration
    
    /// Connection parameters for the task.
    private let request: URLRequest
    
    // MARK: - State
    
    /// Transport WebSocket connection with the server.
    private var socket: WebSocket?
    
    /// Holds information about the connection health and what the client is doing about it.
    private(set) var health: Health = Health.notconnected
    
    enum Health: Equatable {

        /// Connection is healthy and client can communicate with the server.
        case acknowledged

        /// Connection with the server hasn't been established yet.
        case notconnected
        
        /// We have started connecting with the server but the connection hasn't been established yet.
        case connecting
        
        /// A connetion has been established with the server, but the server hasn't acknowledged the connection yet.
        case connected

        /// Server is unreachable and client is trying to reconnect.
        case reconnecting(retry: Int)
    
        /// The client has been disposed and we shouldn't attempt to make any new connections.
        case disposed
        
        /// Returns a string description of the health.
        var description: String {
            switch self {
            case .acknowledged:
                return "acknowledged"
            case .notconnected:
                return "notconnected"
            case .connecting:
                return "connecting"
            case .connected:
                return "connected"
            case .reconnecting(retry: let retry):
                return "reconnecting (\(retry))"
            case .disposed:
                return "disposed"
            }
        }
    }
    
    /// Queue of messages that should be sent to the server.
    ///
    /// - NOTE: The 0-th message should be sent first.
    private var queue = [ClientMessage]()
    
    public enum Event {
        /// Client started connecting.
        case connecting
        
        /// WebSocket has opened.
        case opened(socket: WebSocketClient)

        /// Open WebSocket connection has been acknowledged
        case acknowledged(payload: [String: AnyCodable]?)
        
        /// Ping has been sent.
        case pingSent
        
        /// Pong has been received.
        case pongReceived
        
        /// A message from the server has been received.
        case message(ServerMessage)
        
        /// WebSocket connection has closed.
        case closed
        
        /// WebSocket connection had an error or client had an internal error.
        case error(Error)
    }
    
    /// The central subject that publishes all events to the pipelines.
    private let emitter = PassthroughSubject<Event, Never>()
    
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
    /// query identifier that the client used to identify the subscription.
    ///
    /// - NOTE: We also use pipelines to tell how many ongoing connections the client is managing.
    private(set) var pipelines = [String: AnyCancellable]()
    
    // MARK: - Initializer
    
    /// Creates a new GraphQL WebSocket client from the given connection.
    public init(
        request: URLRequest,
        config: GraphQLWebSocketConfiguration = GraphQLWebSocketConfiguration()
    ) {
        self.request = request
        self.config = config
        
        if self.config.behaviour == .eager {
            self.connect()
        }
    }

    // MARK: - Internals
    
    public func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        self.config.logger.debug("Received a new message from the server!")
        
        switch event {
        case let .connected(protocolName):
            self.config.logger.debug("Socket connected!")
            // NOTE: only 1 protocol is supported
            assert(ClientMessage.PROTOCOL == protocolName, "Unsupported protocol")
            
            // Immediatelly notify all listeners about the health change.
            self.emitter.send(Event.opened(socket: client))
            self.health = .connected
            
            // Once the connection opens, we start recursively processing server messages.
            if self.config.connectionAckTimeout > 0 {
                self.config.logger.debug("Scheduling connection acknowledge timeout timer...")
                
                self.ackTimer = Timer.scheduledTimer(
                    withTimeInterval: TimeInterval(self.config.connectionAckTimeout),
                    repeats: false,
                    block: { _ in
                        self.socket?.disconnect(closeCode: CloseCode.connectionAcknowledgementTimeout)
                    })
            }
            
            let payload = self.config.connectionParams()
            self.send(message: ClientMessage.initalise(payload: payload))
            
        case .text(let string):
            self.config.logger.debug("Received 'text' data from the server.")
            guard let message = try? self.config.decoder.decode(ServerMessage.self, from: Data(string.utf8)) else {
                break
            }
            self.tick(result: .success(message))
            break
                        
        case .binary(let data):
            self.config.logger.debug("Received 'binary' data from the server.")
            guard let message = try? self.config.decoder.decode(ServerMessage.self, from: data) else {
                break
            }
            self.tick(result: .success(message))
            break
            
        case .error(let error):
            let msg = error?.localizedDescription ?? "unknown"
            self.config.logger.debug("There was an error in socket (\(msg)).")
            
            if let error = error {
                self.tick(result: .failure(error))
            }
            break

        case .pong:
            self.config.logger.debug("Received pong from the server...")
            self.emitter.send(.pongReceived)
            self.connectionDroppedTimer?.invalidate()
            break
            
        case .disconnected(_, let closeCode):
            self.close(code: closeCode)
            break
        }
    }
    
    /// Creates a new socket connection and kicks-off the communication with the server.
    private func connect() {
        self.config.logger.debug("Connection initiated (\(self.health.description))...")
        
        // Prevent the timer from closing the socket because
        // a new pipeline was created.
        self.lazyCloseTimer?.invalidate()
        
        switch self.health {
        case .notconnected, .reconnecting:
            // https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md#communication
            var request = self.request
            request.setValue(ClientMessage.PROTOCOL, forHTTPHeaderField: "Sec-WebSocket-Protocol")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            
            let socket = WebSocket(request: request)
            socket.delegate = self
            self.socket = socket
            self.config.logger.debug("Socket created!")
            
            socket.connect()
            self.health = .connecting
            
            self.config.logger.debug("Socket connecting...")
            break
            
        default:
            self.config.logger.debug("Connection already established, skipping!")
            break
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
                guard let self = self, self.pipelines.isEmpty else {
                    return
                }
                
                self.config.logger.debug("Closing the connection!")
                self.socket?.disconnect(closeCode: CloseCode.normalClosure)
            })
    }
    
    /// Correctly closes the connection with the server.
    private func close(code: Int) {
        self.config.logger.debug("Connection with the server closed (\(code))!")
        
        // The server shouldn't reconnect, we tell all listenerss to stop listening.
        guard shouldRetryToConnect(code: code) else {
            self.emitter.send(Event.closed)
            
            self.pingTimer = nil
            self.lazyCloseTimer = nil
            self.ackTimer = nil
            self.reconnectTimer = nil
            self.connectionDroppedTimer = nil
            
            self.health = .notconnected
            
            self.config.logger.debug("Terminated connection and cleared timers!")
            
            return
        }
        
        self.config.logger.debug("Reconnecting...")
        var retry: Int = 1
        if case .reconnecting(let attempt) = health {
            retry = attempt
        }
        
        self.health = .reconnecting(retry: retry + 1)
        
        self.config.logger.debug("Scheduling \(retry)-th connect retry!")
        self.reconnectTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(self.config.retryWait(retry)),
            repeats: false,
            block: { [weak self] _ in
                // A reconnect should always happen if the client connects eagerly,
                // even if we have no current listeners.
                guard let self = self, !self.pipelines.isEmpty || self.config.behaviour == .eager else {
                    return
                }
                
                self.config.logger.debug("Reconnection in progress...")
                self.connect()
            })
    }
    
    /// Sends a message using the websocket transport.
    private func send(message: ClientMessage) {
        guard let socket = self.socket else {
            self.config.logger.debug("Socket not ready, queueing message \(message.description)...")
            self.queue.append(message)
            return
        }
        
        let data = try! self.config.encoder.encode(message)
        switch (self.health, message) {
        case (.acknowledged, _), (.disposed, _), (_, .initialise):
            // We can send any message when the connection has been ACK and meta messages when the server hasn't ACK the connection yet.
            socket.send(data) { _ in }
            self.config.logger.debug("\(message.description) sent to the server!")
            
        default:
            self.config.logger.debug("Transport not ready, queueing message \(message.description)...")
            self.queue.append(message)
        }
    }
    
    /// Empties the message queue if possible.
    private func flushQueue() {
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
        self.socket?.sendPing(pongReceiveHandler: { _ in }) // NOTE: sent also via delegate
        self.emitter.send(Event.pingSent)
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
                self.socket?.disconnect(closeCode: CloseCode.noStatusReceived)
            })
    }
    
    /// Processes a management message from the server and forwards data message
    /// to event listeners.
    private func tick(result:  Result<ServerMessage, Error>) {
        self.connectionDroppedTimer?.invalidate()
        self.config.logger.debug("Processing server message...")
        
        switch (self.health, result) {
            
        case (.connected,.success(.acknowledge(let msg))):
            self.config.logger.debug("Received ACK message!")
            
            self.emitter.send(Event.message(.acknowledge(msg)))
            self.emitter.send(Event.acknowledged(payload: msg.payload))
            
            self.health = .acknowledged
            self.ackTimer?.invalidate()
            self.flushQueue()
            
            guard self.config.keepAlive > 0 else {
                break
            }
            
            self.config.logger.debug("Scheduling a ping timer.")
            
            // We override the old timer and drop it. This way, the client
            // only sends ping event when the server hasn't replied in a while.
            self.pingTimer = Timer.scheduledTimer(
                withTimeInterval: TimeInterval(self.config.keepAlive),
                repeats: false,
                block: { [weak self] _ in
                    guard let self = self else { return }
                    self.ping()
                })
            
            
            break
        
        case (.connected, .success(_)):
            self.config.logger.debug("Received an invalid first message. Closing socket!")
            
            // If the previous statement didn't catch this message, we got an invalid
            // message before acknowledgement.
            self.socket?.disconnect(closeCode: CloseCode.badResponse)
            return
        
        case (_, .success(let msg)):
            self.emitter.send(Event.message(msg))
            
        case (_, .failure(let err)):
            // As soon as the reading of the message fails, emit an error and stop
            // processing new messages.
            self.emitter.send(Event.error(err))
            self.socket?.disconnect(closeCode: CloseCode.badResponse)
            return
        }
    }
    
    /// Checks the state of the client and tells whether the client should try reconnecting to the
    /// server given the received event.
    private func shouldRetryToConnect(code: Int) -> Bool {
        
        // Client was disposed and we shouldn't retry to reconnect.
        if case .disposed = self.health {
            return false
        }
        
        if CloseCode.isFatalInternalCloseCode(code: code) || CloseCode.isTerminatingCloseCode(code: code) {
            return false
        }
        
        // Check that all locks have been released when receiving a regular closure.
        if (code == CloseCode.normalClosure.rawValue) {
            return self.pipelines.count > 0
        }
        
        // Prevent infinite retrying.
        if case let .reconnecting(retries) = self.health, retries >= self.config.retryAttempts {
            return false
        }
        
        return true
    }
    
    // MARK: - Methods
    
    /// Returns a stream of events that get triggered when the client's state changes.
    public func onEvent() -> AnyPublisher<Event, Never> {
        self.emitter.share().eraseToAnyPublisher()
    }
    
    /// Correctly closes the connection with the server.
    public func close(code: CloseCode = .normalClosure) {
        // NOTE: this does NOT close connection if there are not complete subscriptions
        // TODO: does it make sense to expose it? this is confusing, add `force` flag at the very least?
        // TODO: does it make sense to allow client set closeCode?
        close(code: code.rawValue)
    }
    
    /// Creates a publisher that emits results received from the server
    /// of the provided query.
    ///
    /// - NOTE: The client sends the request to the server once a subscriber has
    ///         subscribed - not as soon as you call `subscribe` method.
    public func subscribe(_ args: ExecutionArgs) -> AnyPublisher<ExecutionResult, Never> {
        let id = UUID().uuidString
        
        // We create a new publisher that is bound to the pipeline
        // that watches server events and forwards them to the subscriber.
        // There's one pipeline for every subscription.
        let subject = PassthroughSubject<ExecutionResult, Never>()
        
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
                    // NOTE: Validation errors returned as standalone
                    // messages terminate the stream (https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md#error)
                    // that's why we close the pipeline.
                    
                    let result = ExecutionResult(
                        data: AnyCodable(nil),
                        errors: payload.payload,
                        hasNext: false,
                        extensions: [:]
                    )
                    subject.send(result)
                    subject.send(completion: .finished)
                    
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
