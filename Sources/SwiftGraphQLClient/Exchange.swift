import Combine
import Foundation
import GraphQL

/// Operation describes a single request that may be processed by multiple exchange along the chain.
public struct Operation: Identifiable, Equatable, Hashable {
    
    /// Unique identifier used to identify an operation.
    public var id: String
    
    /// Identifies the operation type.
    public var kind: Kind
    
    public enum Kind: String {
        case query
        case mutation
        case subscription
        case teardown
    }
    
    /// Request that we should use to send this operation.
    ///
    ///  - NOTE: You should extend the request using exchanges.
    public var request: URLRequest
    
    /// Specifies the caching-networking mechanism that exchanges should follow.
    public var policy: Policy
    
    public enum Policy {
        
        /// Prefers cached results and falls back to sending an API request when there are no prior results.
        case cacheFirst
        
        /// Will always return cached results or null.
        case cacheOnly
        
        /// Will always send a network request and ignore cached values.
        case networkOnly
        
        /// Returns cached results but also always sends an API request.
        case cacheAndNetwork
        
        /// Tells whether the operation requires a network call.
        public var isNetwork: Bool {
            self == .networkOnly || self == .cacheAndNetwork
        }
    }
    
    /// Types that appear in the request.
    ///
    /// - NOTE: This may be used invalidate the cache.
    public var types: [String]
    
    /// GraphQL parameters for this request.
    public var args: ExecutionArgs
}

extension Operation {
    
    /// Returns an operation that is exactly the same as the current one and has
    /// an updated kind value.
    func with(kind: Operation.Kind) -> Operation {
        var copy = self
        copy.kind = kind
        return copy
    }
}

/// A structure describing the result of an operation execution.
public struct OperationResult {
    /// Back-reference to the operation that triggered the execution.
    public var operation: Operation
    
    /// Data received from the server.
    public var data: Data?
    
    /// Errors accumulated along the execution path.
    public var errors: [CombinedError]
    
    /// Optional stale flag added by exchanges that return stale results.
    public var stale: Bool?
}

extension OperationResult {
    /// Changes the `stale` value fo the operation result on a copy of the current instance.
    func with(stale: Bool) -> OperationResult {
        var copy = self
        copy.stale = stale
        return copy
    }
}

/// A structure describing decoded result of an operation execution.
///
/// - NOTE: Decoded result may include errors from invalid data even if
///         the response query was correct.
public struct DecodedOperationResult<T: Decodable> {
    
    /// Back-reference to the operation that triggered the execution.
    public var operation: Operation
    
    /// Decoded response.
    public var data: T?
    
    /// Errors from the execution.
    public var errors: [CombinedError]
    
    /// Tells wether the result of the query is ot up-to-date.
    public var stale: Bool?
}

/// An error structure describing an error that may have happened in one of the exchanges.
public enum CombinedError: Error {
    
    /// Describes errors that occur on the networking layer.
    case network(Error)
    
    /// Describes errors that occured during the GraphQL execution.
    case graphql(GraphQLError)
    
    /// Describes errors that occured during the parsing phase on the client.
    case parsing(Error)
}

/// Utility type for describing the exchange processor.
///
/// - NOTE: Even though it may seem like the operation stream (downstream) and result stream (upstream) are separate,
///         we usually map operations to results and preserve the stream.
typealias ExchangeIO = (AnyPublisher<Operation, Never>) -> AnyPublisher<OperationResult, Never>

/// Exchange is a link in the chain of operation processors.
protocol Exchange {
    /// Register function receives a stream of operations and the next exchange in the chain
    /// and should return a stream of results.
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: @escaping ExchangeIO
    ) -> AnyPublisher<OperationResult, Never>
}