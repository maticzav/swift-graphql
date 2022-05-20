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
    
    /// Optional parameters, passed through the `payload` field with the `ConnectionInit` message,
    /// that the client specifies when establishing a connection with the sever.
    ///
    /// You can use this for securely passing arguments for authentication.
    public var connectionParams: [String: AnyCodable]? = nil
    
    /// Controls when the client should establish a connection with the server.
    public var behaviour: Behaviour = .lazy(closeTimeout: 0)
    
    public enum Behaviour: Equatable {
        // https://stackoverflow.com/questions/5427949/what-is-the-opposite-of-lazy-loading
        
        /// Client immediately establishes a connection.
        case eager
        
        /// Establishes a connection on first subscribe and close on last unsubscribe.
        ///
        /// - parameter closeTimeout: Tells how long the client should wait before closing the socket after the last operation has completed.
        case lazy(closeTimeout: Int)
    }
    
    /// Timeout between dispatched keep-alive messages (i.e. server pings). The client internally
    /// dispatches the `PingMessage` type to the server and expects a `PongMessage` in response.
    ///
    /// Timeout countdown starts from the moment the socket was opened and subsequently after every received `PongMessage`.
    ///
    ///
    public var keepAlive: Int = 0
    
    /// How many times should the client try to reconnect on abnormal socket closure before it errors out?
    ///
    /// The library classifies the following close events as fatal:
    /// - _All internal WebSocket fatal close codes (check `isFatalInternalCloseCode` in `src/client.ts` for exact list)_
    /// - `4500: Internal server error`
    /// - `4005: Internal client error`
    /// - `4400: Bad request`
    /// - `4004: Bad response`
    /// - `4401: Unauthorized` _tried subscribing before connect ack_
    /// - `4406: Subprotocol not acceptable`
    /// - `4409: Subscriber for <id> already exists` _distinction is very important_
    /// - `4429: Too many initialisation requests`
    ///
    /// These events are reported immediately and the client will not reconnect.
    public var retryAttempts: Int = 5
    
    /// Custom function that returns the wait time in milliseconds after a given number of retries.
    public var retryWait: (Int) -> Int = { i in
        // random exponantial backoff
        1000 * 2 ^ i + Int.random(in: 300..<3000)
    }
    
    /// Number of seconds that the server waits before closing the unacknowledged connection.
    ///
    /// - NOTE: If set to 0, it won't close.
    public var connectionAckTimeout: Int = 0
    
    /// Session that should be used to create a WebSocket task.
    public var session: URLSession
    
    /// Connection parameters for the task.
    public var request: URLRequest
    
    /// Shared encoder used to encode the request.
    public var encoder: JSONEncoder = JSONEncoder()
    
    /// Shared decoder used for decoding responses.
    public var decoder: JSONDecoder = JSONDecoder()
    
    /// Logger that we use to communitcate state changes inside the WebSocket.
    public var logger: Logger = Logger(subsystem: "graphql", category: "socket")
    
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
    
    /// Holds references to pipelines created by subscriptions. Each pipeline is identified by the
    /// query id of the subscription that created a pipeline.
    ///
    /// - NOTE: We also use pipelines to tell how many ongoing connections the client is managing.
    private var pipelines = [String: AnyCancellable]()
    
    // MARK: - Initializer
    
    /// Creates a new GraphQL WebSocket client from the given connection.
    public init(session: URLSession, request: URLRequest) {
        self.session = session
        self.request = request
        
        super.init()
        
        if self.behaviour == .eager {
            self.connect()
        }
    }

    // MARK: - Internals
    
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        
        // Immediatelly notify all listeners about the health change.
        self.emitter.send(Event.opened(socket: webSocketTask))
        self.health = .connecting
        
        // Once the connection opens, we start recursively processing server messages.
        guard self.connectionAckTimeout > 0 else {
            return
        }
        
        self.ackTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(self.connectionAckTimeout),
            repeats: false,
            block: { _ in
                let message = Data("Connection acknowledgement timeout".utf8)
                self.socket?.cancel(with: .goingAway, reason: message)
            })
        
        self.send(message: ClientMessage.initalise(payload: self.connectionParams))
        self.flushQueue()
        
        self.tick()
    }
    
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        // The server shouldn't reconnect, we tell all listeners to stop listening.
        guard shouldRetryToConnect(code: closeCode) else {
            self.emitter.send(Event.closed)
            return
        }
        
        var retry: Int = 0
        if case .reconnecting(let attempt) = health {
            retry = attempt
        }
        
        self.reconnectTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(self.retryWait(retry)),
            repeats: false,
            block: { [weak self] _ in
                // A reconnect should always happen if the client connects eagerly,
                // even if we have no current listeners.
                guard let self = self, !self.pipelines.isEmpty, self.behaviour != .eager else {
                    return
                }
                
                self.connect()
            })
    }
    
    /// Creates a new socket connection and kicks-off the communication with the server.
    private func connect() {
        // Prevent the timer from closing the socket because
        // a new pipeline was created.
        self.lazyCloseTimer?.invalidate()
        
        switch self.health {
        case .acknowledged:
            return
        default:
            let socket = self.session.webSocketTask(with: self.request)
            
            socket.delegate = self
            self.socket = socket
            
            socket.resume()
        }
    }
    
    /// Prepares the client to disconnect if necessary once the connecction has dropped.
    private func disconnect() {
        guard case .lazy(let timeout) = self.behaviour, self.health == .acknowledged else {
            return
        }
        
        self.lazyCloseTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(timeout),
            repeats: false,
            block: { [weak self] _ in
                guard let self = self, self.pipelines.isEmpty, self.socket?.state == .running else {
                    return
                }
                
                let message = Data("Normal Closure".utf8)
                self.socket?.cancel(with: URLSessionWebSocketTask.CloseCode.normalClosure, reason: message)
            })
    }
    
    /// Decodes the next socket message received from the server and forwards it to the handler.
    private func receiveServerMessage(handler: @escaping (Result<ServerMessage, Error>) -> Void) {
        self.socket?.receive { [weak self] result in
            guard let self = self else {
                return
            }
            
            var message: ServerMessage? = nil
            switch result {
            case .success(.string(let str)):
                message = try? self.decoder.decode(ServerMessage.self, from: Data(str.utf8))
            case .success(.data(let data)):
                message = try? self.decoder.decode(ServerMessage.self, from: data)
            case .failure(let error):
                handler(.failure(error))
                return
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
            self.queue.append(message)
            return
        }
        
        let data = try! self.encoder.encode(message)
        socket.send(.data(data)) { [weak self] err in
            if let self = self, let err = err {
                self.emitter.send(Event.error(err))
            }
        }
    }
    
    /// Empties the queue if possible.
    private func flushQueue() {
        guard self.socket?.state == .running else {
            return
        }

        while !self.queue.isEmpty {
           self.send(message: self.queue.removeFirst())
        }
    }
    
    /// Processes a management message from the server and forwards data message
    /// to event listeners.
    private func tick() {
        self.receiveServerMessage { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch (self.health, result) {
                
            case (.connecting,.success(.acknowledge(let msg))):
                self.emitter.send(Event.connected(payload: msg.payload))
                
                self.health = .acknowledged
                self.ackTimer?.invalidate()
                
                if self.keepAlive > 0 {
                    self.pingTimer = Timer.scheduledTimer(
                        withTimeInterval: TimeInterval(self.keepAlive),
                        repeats: true,
                        block: { [weak self] _ in
                            guard let self = self else {
                                return
                            }
                            
                            self.send(message: ClientMessage.ping())
                            self.emitter.send(Event.ping(received: false, payload: nil))
                        }
                    )
                }
                break
            
            case (.connecting, .success):
                let message = Data("First message has to be ACK".utf8)
                self.socket?.cancel(with: URLSessionWebSocketTask.CloseCode.policyViolation, reason: message)
                return
                
            case (_, .success(.ping(let msg))):
                self.emitter.send(Event.ping(received: true, payload: nil))
                self.send(message: ClientMessage.pong(payload: msg.payload))
                self.emitter.send(Event.pong(received: false, payload: msg.payload))
                break
                
            case (_, .success(.pong(let msg))):
                self.emitter.send(Event.pong(received: true, payload: msg.payload))
                break
            
            case (_, .success(let msg)):
                self.emitter.send(Event.message(msg))
                break
                
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
        
        if case let .reconnecting(retries) = self.health, retries >= self.retryAttempts {
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
                self.send(message: ClientMessage.subscribe(id: id, payload: args))
                self.connect()
            }, receiveCompletion: { completion in
                // Server has stopped sending requests, we just clear up the resources.
                self.pipelines.removeValue(forKey: id)
            }, receiveCancel: {
                // User has cancelled the subscription. We notify the server
                // to stop sending results and free memory allocated to processing the subscription.
                self.send(message: ClientMessage.complete(id: id))
                self.pipelines.removeValue(forKey: id)
                self.disconnect()
            })
            .eraseToAnyPublisher()
        
        return results
    }
    
}
