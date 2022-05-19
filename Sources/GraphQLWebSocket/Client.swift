// This file is heavily inspired by https://github.com/enisdenjo/graphql-ws.

import Combine
import GraphQL
import Foundation
import os

/// A GraphQL client that lets you send queries over WebSocket protocol.
///
/// - NOTE: The client assumes that you'll manually establish the socket connection
///         and that it may send requests.
public class GraphQLWebSocket {
    
    /// Optional parameters, passed through the `payload` field with the `ConnectionInit` message,
    /// that the client specifies when establishing a connection with the sever.
    ///
    /// You can use this for securely passing arguments for authentication.
    public var connectionParams: [String: AnyCodable]? = nil
    
    /// Controls when the client should establish a connection with the server.
    public var behaviour: Behaviour = .lazy(closeTimeout: 0)
    
    public enum Behaviour {
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
    
    /// Holds information about the connection health and what the client is doing about it.
    private var health: Health = .connecting

    // socket ---> connect (retries, connection ack, init) ----> subscriptions
    
    private enum Health {

        /// Connection is healthy and client can communicate with the server using a given task.
        case active(publisher: WebSocketTaskPublisher)

        /// Connection with the server hasn't been established yet.
        case connecting

//        /// Server is unreachable and client is trying to reconnect.
//        case reconnecting(retry: Int)
    }
    
    /// Tells whether the server has been disposed.
    ///
    /// - NOTE: Server may be in any of the states when it's disposing, that's why it's not a separate health case.
    private var disposed: Bool = false
    
    /// Listeners identified by the id of the pipeline.
    ///
    /// - NOTE: When the subscriber no longer listens for the events of the listener
    ///         it should remove it from the dictionary.
    private var listeners = [String: DisposablePublisher<StateEvent, Never>]()
    
    /// Queue of messages that should be sent to the server.
    ///
    /// - NOTE: The first message to be sent has index zero.
    private var queue = [ClientMessage]()
    
    public enum StateEvent {
        /// Client started connecting.
        case connecting
        
        /// WebSocket has opened.
        case opened(socket: URLSessionWebSocketTask)
        
        /// Open WebSocket connection has been acknowledged
        case connected(socket: URLSessionWebSocketTask, payload: [String: AnyCodable]?)
        
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
    
    /// Holds references to pipelines created by subscriptions. Each pipeline is identified by the
    /// query id of the subscription that created a pipeline.
    ///
    /// - NOTE: We also use pipelines to tell how many ongoing connections the client is managing.
    private var pipelines = [String: AnyCancellable]()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    /// Creates a new GraphQL WebSocket client from the given connection.
    ///
    /// - parameter timeout: Number of seconds before a ping request is sent.
    public init(session: URLSession, request: URLRequest) {
        self.session = session
        self.request = request
    }

    // MARK: - Internals
    
    /// Sends a message using the websocket transport.
    private func send(message: ClientMessage) {
        let data = try! self.encoder.encode(message)
        let message: URLSessionWebSocketTask.Message = .data(data)
        
        
    }
    
    /// Flushes the queue one message at a time.
    private func flush() throws {
        while !self.queue.isEmpty {
            self.send(message: self.queue.removeFirst())
        }
    }
    
    /// Establishes a connection with the server and connects event listeners to the server stream.
    /// In case the server failed to reconnect on error, we dispose of all listeners.
    private func connect(id: String) -> DisposablePublisher<StateEvent, Never> {
        switch self.health {
        case .active:
            ()
        case .connecting:
            let publisher = self.session.websocketTaskPublisher(for: self.request)
            
            publisher
                .map { message in
                    switch message {
                    case .string(let str):
                        return Data(str.utf8)
                    case .data(let data):
                        return data
                    @unknown default:
                        fatalError()
                    }
                }
                .decode(type: ServerMessage.self, decoder: self.decoder)
                .map { msg -> StateEvent in
                    .message(msg)
                }
                .catch({ err -> AnyPublisher<StateEvent, Never> in
                    Just(.error(err)).eraseToAnyPublisher()
                })
                .sink { completion in
                    for listener in self.listeners {
                        listener.value.send(completion: completion)
                    }
                } receiveValue: { value in
                    for listener in self.listeners {
                        listener.value.send(value)
                    }
                }
                .store(in: &self.cancellables)
        }
        
        let listener = DisposablePublisher<StateEvent, Never>() {
            self.listeners.removeValue(forKey: id)
        }
        
        self.listeners[id] = listener
        
        return listener
    }
    
    /// Releases the connection with the server for an operation with a given id.
    private func release(id: String) {
        self.listeners[id]?.dispose()
        
        // Check that we haven't disposed the connection already.
        if let pipeline = self.pipelines[id] {
            self.send(message: ClientMessage.complete(id: id))
        }
        
        self.pipelines.removeValue(forKey: id)
    }
    
    // MARK: - Calculations
    
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
    
    enum TerminationEvent {
        /// Server has sent a close event with a given code
        case closeEvent(code: Int)
    }
    
    /// Checks the state of the client and tells whether the client should try reconnecting to the
    /// server given the received event.
    private func shouldRetryToConnect(event: TerminationEvent) -> Bool {
        
        // Client was disposed and we shouldn't retry to reconnect.
        if self.disposed {
            return false
        }
        
        switch (event) {
        case let .closeEvent(code):
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
                .contains(code)
            
            if Self.isFatalInternalCloseCode(code: code) || isTerminatingCloseCode {
                return false
            }
            
            // Check that all locks have been released when receiving a regular closure.
            if (code == 1000) {
                return self.pipelines.count > 0
            }
            
//            if case let .reconnecting(retries) = self.health, retries >= self.retryAttempts {
//                return false
//            }
        }
        
        return true
    }
    
    // MARK: - Methods
    
    /// Returns a stream of events that get triggered when the client's state changes.
    public func onEvent() -> DisposablePublisher<StateEvent, Never> {
        let id = UUID().uuidString
        return self.connect(id: id)
    }
    
    /// Creates a subscription stream for a given query.
    public func subscribe(_ args: ExecutionArgs) -> DisposablePublisher<ExecutionResult, Error> {
        let id = UUID().uuidString
        
        // We create a new publisher that is bound to the pipeline
        // that watches server events and forwards them to the subscriber.
        let subject = DisposablePublisher<ExecutionResult, Error> {
            self.release(id: id)
        }
        
        let pipeline = self.connect(id: id).share()
            .compactMap({ state -> ServerMessage? in
                switch state {
                case .message(let message):
                    return message
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
                    // NOTE: We send validation errors return in a standalone
                    // server message as possibly terminating events down the stream
                    // since we don't expect to receive any other events.
                    subject.send(completion: .failure(payload.payload))
                    
                case .complete:
                    subject.send(completion: .finished)
                default:
                    ()
                }
            }
        
        self.pipelines[id] = pipeline
        self.send(message: ClientMessage.subscribe(id: id, payload: args))
        
        return subject
    }
    
    ///
    func dispose() {
        self.disposed = true
        if case .connecting = health {
            
        }
    }
    
}

