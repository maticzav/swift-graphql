import GraphQL
import Foundation

import Logging

/// Structure that lets you configure WebSocket's behaviour.
///
/// - NOTE: You should create a new configuration instance that holds default settings
///         and change the parts that you want to configure.
public struct GraphQLWebSocketConfiguration {
    
    /// Optional parameters, passed through the `payload` field with the `ConnectionInit` message,
    /// that the client specifies when establishing a connection with the sever.
    ///
    /// You can use this for securely passing arguments for authentication.
    public var connectionParams: () -> [String: AnyCodable]? = { nil }
    
    /// Controls when the client should establish a connection with the server.
    public var behaviour: Behaviour = .eager
    
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
    /// dispatches the `PingMessage` type to the server and expects a `PongMessage` in response or any
    /// other valid sign of running connection.
    ///
    /// Timeout countdown starts from the moment the socket was opened and subsequently after every received `PongMessage`
    /// or any other regular message. If the server doesn't reply in `3 x keepAlive` time, the client considers
    /// that a connection dropped.
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
    
    /// Logger that we use to communitcate state changes inside the WebSocket.
    public var logger: Logger = Logger(label: "graphql.socket")
    
    /// JSON encoder that's used to encode GraphQL query requests.
    public var encoder: JSONEncoder = JSONEncoder()
    
    /// JSON decoder that's used to decode JSON responses received from the server.
    public var decoder: JSONDecoder = JSONDecoder()
    
    /// Creates a new WebSocket configuration with default values for all parameters.
    public init() {}
}

