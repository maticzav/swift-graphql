import Foundation
import Combine
import GraphQL
import os

/// Protocol that outlines a websocket-compatible structure.
public protocol WebSocket: Publisher where Failure == Error, Output == URLSessionWebSocketTask.Message {
    /// Sends a WebSocket message, receiving the result in a completion handler.
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void)
    
    /// Stops the communication channel.
    func close() -> Void
}

/// A GraphQL client that lets you send queries over WebSocket protocol.
///
/// - NOTE: The client assumes that you'll manually establish the socket connection
///         and that it may send requests.
public class GraphQLSubscriptionClient<Socket: WebSocket> {
    
    /// Main WebSocket communication channel between the server and the client.
    private let socket: Socket
    
    /// Publisher of the stream
    private var stream: AnyPublisher<Data, Error>
    
    /// Connection is a connection within the established socket describing a channel through which the operation requests will be communicated.
    ///
    /// - NOTE: All connections share the same socket and each subscription creates
    ///         a new connection.
    struct Connection<TypeLock>: Identifiable {
        var id: UUID
    
        var status: Status
        
        enum Status {
            /// Client has successfully subscribed to the server events.
            case subscribed
            
            /// Client or server has ended the communication.
            case closed
        }
        
        /// Stream of payloads for a given subscription.
        var publisher: AnyPublisher<TypeLock, Error>
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Queue of messages that should be sent to the server.
    ///
    /// - NOTE: The first message to be sent has index zero.
    private var queue = [ClientMessage]()
    
    enum State {
        /// Client has sent an initialisation
        case notestablished
        
        /// The server has sent initialisation request but hasn't received reply yet.
        case initialising
        
        /// Server has acknowledge the connection and we can start subscribing.
        case active
        
        /// Server hasn't responded for a while.
        case lost
    }
    
    /// Tells whether the server has acknowledge the connection.
    private var state: State = .notestablished {
        didSet {
            try? self.flush()
        }
    }
    
    /// Shared encoder used to encode the request.
    private var encoder: JSONEncoder = JSONEncoder()
    
    /// Shared decoder used for decoding responses.
    private var decoder: JSONDecoder = JSONDecoder()
    
    /// Logger that we use to communitcate state changes inside the WebSocket.
    private var logger: Logger = Logger(subsystem: "graphql", category: "socket")
    
    // MARK: - Initializer
    
    /// Creates a new GraphQL WebSocket client from the given connection.
    ///
    /// - parameter timeout: Number of seconds before a ping request is sent.
    init(
        socket: Socket,
        timeout: Double
    ) {
        self.socket = socket
        
        self.stream = self.socket
            .compactMap({ message in
                switch message {
                case .data(let data):
                    return data
                default:
                    return nil
                }
            })
            .share()
            .eraseToAnyPublisher()
        
        // We debounce for a given interval before sending a ping request.
        // This results in us sending a ping request after the timeout.
        self.socket
            .debounce(for: .seconds(timeout), scheduler: RunLoop.main)
            .sink { _ in } receiveValue: { _ in
                try? self.send(message: ClientMessage.ping())
            }
            .store(in: &self.cancellables)

    }
    
    // MARK: - Methods
    
    /// Creates a subscription stream for a given query.
    func subscribe<TypeLock: Decodable & Equatable>(_ args: ExecutionArgs) throws -> AnyPublisher<ExecutionResult<TypeLock>, Error> {
        let id = UUID()
        
        let subject = PassthroughSubject<ExecutionResult<TypeLock>, Error>()
        let connection = Connection<ExecutionResult<TypeLock>>(
            id: id,
            status: .subscribed,
            publisher: subject.eraseToAnyPublisher()
        )
        
        logger.log("new subscription: \(id)")
        
        // Set up event handler.
        self.stream
            .decode(type: ServerMessage<TypeLock>.self, decoder: self.decoder)
            .tryFilter({ [weak self] message in
                // Process internal requests and filter the ones relevant to the subscriber.
                
                guard let self = self else {
                    return false
                }
                
                switch message {
                case .acknowledge:
                    self.logger.debug("server acknowledged")
                    
                    self.state = .active
                    return false
                case .ping(let msg):
                    self.logger.debug("server pinged")
                    
                    try self.send(message: ClientMessage.pong(payload: msg.payload))
                    return false
                case .pong:
                    self.logger.debug("server ponged")
                    
                    self.state = .active
                    return false
                case .error(let msg):
                    self.logger.debug("server errored")
                    
                    throw msg.payload
                case .next, .complete:
                    return true
                }
            })
            .sink(receiveCompletion: { completion in
                self.logger.log("connection torn down")
                
                subject.send(completion: completion)
            }, receiveValue: { message in
                switch message {
                case .next(let msg):
                    self.logger.log("received next message")
                    
                    subject.send(msg.payload)
                    break
                case .complete:
                    self.logger.log("received completion")
                    
                    subject.send(completion: .finished)
                    break
                default:
                    break
                }
            })
            .store(in: &self.cancellables)
    
        // Start the socket if necessary.
        if self.state == .notestablished {
            self.state = .initialising
            try self.send(message: ClientMessage.initalise(payload: nil))
        }
        
        // Create the connection.
        let message = ClientMessage.subscribe(id: id.uuidString, payload: args)
        if self.state != .active {
            self.queue.append(message)
        } else {
            try self.send(message: message)
        }
        
        return connection.publisher
    }
    
    // MARK: - Internals
    
    /// Sends a message using the websocket transport.
    private func send(message: ClientMessage) throws {
        let data = try self.encoder.encode(message)
        let message: URLSessionWebSocketTask.Message = .data(data)
        
        self.socket.send(message) { [weak self] error in
            guard let error = error, let self = self else {
                return
            }
            
            self.logger.log("error sending message: \(error.localizedDescription)")
        }
    }
    
    /// Flushes the queue one message at a time.
    private func flush() throws {
        while !self.queue.isEmpty, self.state == .active {
            try self.send(message: self.queue.removeFirst())
        }
    }
}

