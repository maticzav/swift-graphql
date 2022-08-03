// The spec follow https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md.

import Foundation
import GraphQL

/// Represents any messange that may be sent from a client.
protocol ClientMessageInterface: Encodable, Equatable {}

/// Messages that a client may send to the server.
///
/// - __Socket__ is the main WebSocket communication channel between the server and the client
/// - __Connection__ is a connection within the established socket describing a "connection"
///      through which the operation requests will be communicated
///
public enum ClientMessage: Encodable {
    
    /// The WebSocket sub-protocol used for the GraphQL over WebSocket protocol
    public static let PROTOCOL = "graphql-transport-ws"
    
    /// Indicates that the client wants to establish a connection within the existing socket.
    ///
    /// - NOTE: If the server receives more than one `ConnectionInit` message at any given time,
    ///         the server will close the socket with the event `4429: Too many initialisation requests`.
    case initialise(ConnectionInit)
    
    /// A biderctional message used for detailing connection's health.
    case ping(Ping), pong(Pong)
    
    /// A message sent to create sw subscription.
    case subscribe(Subscribe)
    
    /// Indicates that the client has stopped listening and wants to complete the subscription
    case complete(Complete)
    
    public var description: String {
        switch self {
        case .ping:
            return "PING"
        case .pong:
            return "PONG"
        case .initialise:
            return "INIT"
        case .subscribe:
            return "SUBSCRIBE"
        case .complete:
            return "COMPLETE"
        }
    }
    
    // MARK: - Static Utilities
    
    /// Returns an init message with a given payload.
    public static func initalise(payload: [String: AnyCodable]? = nil) -> Self {
        ClientMessage.initialise(ConnectionInit(payload: payload))
    }
    
    /// Returns a pong message with a given payload.
    public static func pong(payload: [String: AnyCodable]? = nil) -> Self {
        ClientMessage.pong(Pong(payload: payload))
    }
    
    /// Returns a ping message with a given payload.
    public static func ping(payload: [String: AnyCodable]? = nil) -> Self {
        ClientMessage.ping(Ping(payload: payload))
    }
    
    /// Returns a subscribe message that may create a new connection with a given ID.
    ///
    /// - parameter id: Desired ID of the connection.
    /// - parameter payload: Arguments used to create a new connection.
    public static func subscribe(id: String, payload: ExecutionArgs) -> Self {
        ClientMessage.subscribe(Subscribe(id: id, payload: payload))
    }
    
    /// Returns a complete message for a connection with a given id.
    ///
    /// - parameter id: The ID of an established connection.
    public static func complete(id: String) -> Self {
        ClientMessage.complete(Complete(id: id))
    }
    
    // MARK: - Interfaces
    
    public enum MessageType: String, CaseIterable, Codable {
        case connection_init = "connection_init"
        case ping = "ping", pong = "pong"
        case subscribe = "subscribe"
        case complete = "complete"
    }
    
    /// Message that indicates that the client wants to establish a connection within the existing socket.
    ///
    /// - NOTE: This connection is not the actual WebSocket communication channel, but is rather
    ///         a frame within it asking the server to allow future operation requests.
    public struct ConnectionInit: ClientMessageInterface, Codable {
        public var type: MessageType = .connection_init
        public var payload: [String: AnyCodable]?
        
        public init(payload: [String: AnyCodable]? = nil) {
            self.payload = payload
        }
    }

    /// Message specification for subscription request.
    public struct Subscribe: ClientMessageInterface, Identifiable {
        public var type: MessageType = .subscribe
        
        /// Unique operation id used to identify the connection channel.
        public var id: String
        
        /// Payload describing the subscription information.
        public var payload: ExecutionArgs

        // MARK: - Init
        
        public init(id: String, payload: ExecutionArgs) {
            self.id = id
            self.payload = payload
        }
    }

    /// Message indicating that the client has stopped listening and wants to complete the subscription.
    ///
    /// - NOTE: No further events, relevant to the original subscription, should be sent through the communication channel.
    public struct Complete: ClientMessageInterface, Identifiable {
        public var type: MessageType = .complete
        
        /// Id identifying the connection channel.
        public var id: String
        
        public init(id: String) {
            self.id = id
        }
    }

    ///  Useful for detecting failed connections, displaying latency metrics or other types of network probing.
    ///
    ///  - NOTE: A Pong message must be sent in response from the receiving party as soon as possible.
    public struct Ping: ClientMessageInterface, Codable {
        public var type: MessageType = .ping
        public var payload: [String: AnyCodable]?
        
        public init(payload: [String: AnyCodable]? = nil) {
            self.payload = payload
        }
    }

    /// Response to the ping message. Must be sent as soon as the ping message is received.
    ///
    /// - NOTE: The pong message can be sent at any time within the established socket. Furthermore,
    ///         the pong message may even be sent unsolicited as an unidirectional heartbeat.
    public struct Pong: ClientMessageInterface, Codable {
        public var type: MessageType = .pong
        public var payload: [String: AnyCodable]?
        
        public init(payload: [String: AnyCodable]? = nil) {
            self.payload = payload
        }
    }
    
    // MARK: - Encoder
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .initialise(let message):
            try message.encode(to: encoder)
        case .ping(let message):
            try message.encode(to: encoder)
        case .pong(let message):
            try message.encode(to: encoder)
        case .subscribe(let message):
            try message.encode(to: encoder)
        case .complete(let message):
            try message.encode(to: encoder)
        }
    }
}

protocol ServerMessageInterface: Decodable, Equatable {}
 
/// Messsages that originate on the server and are sent to the client.
public enum ServerMessage: Equatable, Decodable {
    case acknowledge(ConnectionAck)
    
    /// A biderctional message used for detailing connection's health.
    case ping(Ping), pong(Pong)
    
    /// Server result carrying the next payload.
    case next(Next)
    
    /// Event indicating that something went wrong on the server.
    case error(Error)
    
    /// Indicates that the requested operation execution has completed.
    case complete(Complete)
    
    // MARK: - Interfaces
    
    public enum MessageType: String, CaseIterable, Codable {
        case connection_ack = "connection_ack"
        case ping = "ping", pong = "pong"
        case next = "next"
        case error = "error"
        case complete = "complete"
    }
    
    /// Expected response to the ConnectionInit message from the client acknowledging a connection may
    /// successfully be created. The client is now ready to request a new subscription.
    public struct ConnectionAck: ServerMessageInterface, Codable {
        public var type: MessageType = .connection_ack
        public var payload: [String: AnyCodable]?
        
        public init(payload: [String: AnyCodable]? = nil) {
            self.payload = payload
        }
    }
    
    ///  Useful for detecting failed connections, displaying latency metrics or other types of network probing.
    ///
    ///  - NOTE: A Pong message must be sent in response from the receiving party as soon as possible.
    public struct Ping: ServerMessageInterface, Codable {
        public var type: MessageType = .ping
        public var payload: [String: AnyCodable]?
        
        public init(payload: [String: AnyCodable]? = nil) {
            self.payload = payload
        }
    }

    /// Response to the ping message. Must be sent as soon as the ping message is received.
    ///
    /// - NOTE: The pong message can be sent at any time within the established socket. Furthermore,
    ///         the pong message may even be sent unsolicited as an unidirectional heartbeat.
    public struct Pong: ServerMessageInterface, Codable {
        public var type: MessageType = .pong
        public var payload: [String: AnyCodable]?
        
        public init(payload: [String: AnyCodable]? = nil) {
            self.payload = payload
        }
    }

    /// Operation execution result(s) from the source stream created by the binding subscribe message.
    ///
    /// - NOTE: After all results have been emitted, the completion message will follow indicating stream completion.
    public struct Next: ServerMessageInterface, Identifiable {
        public var type: MessageType = .next
        public var id: String
        public var payload: ExecutionResult
    }

    /// Operation execution error(s) triggered by the next message happening before the
    /// actual execution, usually due to validation errors.
    public struct Error: ServerMessageInterface, Identifiable {
        public var type: MessageType = .error
        
        /// Unique identifier of the connection in the socket.
        public var id: String
        public var payload: [GraphQLError]
        
        public init(id: String, payload: [GraphQLError]) {
            self.id = id
            self.payload = payload
        }
    }
    
    /// Message indicating that the requested operation execution has completed.
    public struct Complete: ServerMessageInterface, Identifiable {
        public var type: MessageType = .complete
        
        /// Id identifying the connection channel.
        public var id: String
        
        public init(id: String) {
            self.id = id
        }
    }
    
    // MARK: - Decoder
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)

        switch type {
        case .connection_ack:
            self = .acknowledge(try ConnectionAck(from: decoder))
        case .ping:
            self = .ping(try Ping(from: decoder))
        case .pong:
            self = .pong(try Pong(from: decoder))
        case .next:
            self = .next(try Next(from: decoder))
        case .error:
            self = .error(try Error(from: decoder))
        case .complete:
            self = .complete(try Complete(from: decoder))
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

// MARK: - Close Code

/// Standard close codes of the GraphQLWS protocol.
public enum CloseCode: UInt16, CaseIterable {
    case normalClosure = 1000
    case goingAway = 1001
    case noStatusReceived = 1005
    case abnormalClosure = 1006
    case serviceRestart = 1012
    case tryAgainLater = 1013
    
    case internalServerError = 4500
    case internalClientError = 4005
    case badRequest = 4400
    case badResponse = 4404
    
    /// Tried subscribing before connection was acknowledged.
    case unauthorized = 4401
    case forbidden = 4403
    case subprotocolNotAcceptable = 4406
    case connectionInitialisationTimeout = 4408
    case connectionAcknowledgementTimeout = 4504
    
    case subscriberAlreadyExists = 4409
    case tooManyInitialisationRequests = 4429
    
    /// Tells whether the provided close code is unrecoverable by the client.
    static func isFatalInternalCloseCode(code: UInt16) -> Bool {
        let recoverable: [UInt16] = [
            CloseCode.normalClosure.rawValue,
            CloseCode.goingAway.rawValue,
            CloseCode.abnormalClosure.rawValue,
            CloseCode.noStatusReceived.rawValue,
            CloseCode.serviceRestart.rawValue,
            CloseCode.tryAgainLater.rawValue,
        ]
        
        if recoverable.contains(code) {
            return false
        }
        
        // All other internal errors are fatal.
        return 1000 <= code && code <= 1999
    }
    
    static func isTerminatingCloseCode(code: UInt16) -> Bool {
        let terminatingCloseCodes = [
            CloseCode.internalServerError.rawValue,
            CloseCode.internalClientError.rawValue,
            CloseCode.badRequest.rawValue,
            CloseCode.badResponse.rawValue,
            CloseCode.unauthorized.rawValue,
            
            CloseCode.subprotocolNotAcceptable.rawValue,
            
            CloseCode.subscriberAlreadyExists.rawValue,
            CloseCode.tooManyInitialisationRequests.rawValue
        ]
        
        return terminatingCloseCodes.contains(code)
    }
}


