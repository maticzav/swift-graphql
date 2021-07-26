/*
 This file contains all types related to messages that may be sent between the client and the server following a GraphQL WebSocket specification.
 */

public typealias ID = String

public enum Event: String, Codable {
    case connecting = "connecting"
    case opened = "opened"
    case connected = "connected"
    case ping = "ping"
    case pong = "pong"
    case message = "message"
    case closed = "closed"
    case error = "error"
}

// MARK: - Messages

public enum MessageType: String, Codable {
    // Client to Server
    case connectioninit = "connection_init"
    case subscribe = "subscribe"
    
    // Server to Client
    case connectionack = "connection_ack"
    case next = "next"
    case error = "error"
    
    // Bidirectional Messages
    case ping = "ping"
    case pong = "pong"
    case complete = "complete"
}

// MARK: - Message Interfaces

public struct ConnectionInitMessage: Codable {
    private(set) public var type = MessageType.connectioninit
    private(set) public var payload: [String: AnyCodable]?
}

public struct ConnectionAckMessage: Codable {
    private(set) public var type = MessageType.connectionack
    private(set) public var payload: [String: AnyCodable]?
}

public struct PingMessage: Codable {
    private(set) public var type = MessageType.ping
    private(set) public var payload: [String: AnyCodable]?
}

public struct PongMessage: Codable {
    private(set) public var type = MessageType.pong
    private(set) public var payload: [String: AnyCodable]?
}

public struct SubscribeMessage: Codable, Identifiable {
    private(set) public var id: ID
    private(set) public var type = MessageType.subscribe
    private(set) public var payload: Payload
    
    public struct Payload: Codable {
        private(set) public var operationName: String?
        private(set) public var query: String
        private(set) public var variables: [String: AnyCodable]?
        private(set) public var extensions: [String: AnyCodable]?
    }
}

public struct NextMessage<Type>: Identifiable {
    private(set) public var id: ID
    private(set) public var type = MessageType.next
    private(set) public var payload: GraphQLResult<Type>
}

extension NextMessage: Encodable where Type: Encodable {}
extension NextMessage: Decodable where Type: Decodable {}

public struct ErrorMessage: Identifiable, Codable {
    private(set) public var id: ID
    private(set) public var type = MessageType.error
    private(set) public var payload: [GraphQLError]
}

public struct CompleteMessage: Identifiable, Codable {
    private(set) public var id: ID
    private(set) public var type = MessageType.complete
}


public enum Message: Codable {
    // Client to Server Messages
    case connectioninit(ConnectionInitMessage)
    case subscribe(SubscribeMessage)
    
    // Server to Client Messages
    case connectionack(ConnectionAckMessage)
    case next(NextMessage<Int>)
    case error(ErrorMessage)
    
    // Bidirectional Messages
    case ping(PingMessage)
    case pong(PongMessage)
    case complete(CompleteMessage)
    
    // MARK: - Initialiser
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)
        
        switch type {
        /* Client -> Server */
        case .connectioninit:
            self = .connectioninit(try ConnectionInitMessage(from: decoder))
        case .subscribe:
            self = .subscribe(try SubscribeMessage(from: decoder))
            
        /* Server -> Client */
        case .connectionack:
            self = .connectionack(try ConnectionAckMessage(from: decoder))
        case .next:
            self = .next(try NextMessage<Int>(from: decoder))
        case .error:
            self = .error(try ErrorMessage(from: decoder))
            
        /* Bidirectional */
        case .ping:
            self = .ping(try PingMessage(from: decoder))
        case .pong:
            self = .pong(try PongMessage(from: decoder))
        case .complete:
            self = .complete(try CompleteMessage(from: decoder))
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case payload
    }
    
    // MARK: - Accessors
    
    /// Returns the type of the message.
    public var type: MessageType {
        switch self {
        /* Client -> Server */
        case .connectioninit(let message):
            return message.type
        case .subscribe(let message):
            return message.type
            
        /* Server -> Client */
        case .connectionack(let message):
            return message.type
        case .next(let message):
            return message.type
        case .error(let message):
            return message.type
            
        /* Bidirectional */
        case .ping(let message):
            return message.type
        case .pong(let message):
            return message.type
        case .complete(let message):
            return message.type
        }
    }
    
    // MARK: - Encoder
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        /* Client -> Server */
        case .connectioninit(let message):
            try message.encode(to: encoder)
        case .subscribe(let message):
            try message.encode(to: encoder)
            
        /* Server -> Client */
        case .connectionack(let message):
            try message.encode(to: encoder)
        case .next(let message):
            try message.encode(to: encoder)
        case .error(let message):
            try message.encode(to: encoder)
            
        /* Bidirectional */
        case .ping(let message):
            try message.encode(to: encoder)
        case .pong(let message):
            try message.encode(to: encoder)
        case .complete(let message):
            try message.encode(to: encoder)
        }
    }
}
