import RxSwiftCombine
import Foundation
import GraphQL

/// Operation describes a single request that may be processed by multiple exchange along the chain.
public struct Operation: Identifiable, Equatable, Hashable {
    public init(id: String, kind: Operation.Kind, request: URLRequest, policy: Operation.Policy, types: [String], args: ExecutionArgs) {
        self.id = id
        self.kind = kind
        self.request = request
        self.policy = policy
        self.types = types
        self.args = args
    }

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
    
    public enum Policy: String {
        
        /// Prefers cached results and falls back to sending an API request when there are no prior results.
        case cacheFirst = "cache-first"
        
        /// Only uses cached results in results.
        ///
        /// - NOTE: Query might not return if there's nothing in the cache.
        case cacheOnly = "cache-only"
        
        /// Will always send a network request and ignore cached values.
        case networkOnly = "network-only"
        
        /// Returns cached results but also always sends an API request.
        case cacheAndNetwork = "cache-and-network"
        
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
    
    /// Returns a new operation that has a modified policy.
    func with(policy: Operation.Policy) -> Operation {
        var copy = self
        copy.policy = policy
        return copy
    }
}

/// A structure describing the result of an operation execution.
public struct OperationResult: Equatable {
    /// Back-reference to the operation that triggered the execution.
    public var operation: Operation
    
    /// Data received from the server.
    public var data: AnyCodable
    
    /// Execution error encontered in one of the exchanges in the chain.
    ///
    /// When we use a GraphQL API there are two kinds of errors we may encounter: Network Errors and GraphQL Errors from the API. Since it's common to encounter either of them, there's a CombinedError class that can hold and abstract either.
    public var error: CombinedError?
    
    /// Optional stale flag added by exchanges that return stale results.
    public var stale: Bool?
    
    public init(
        operation: Operation,
        data: AnyCodable,
        error: CombinedError? = nil,
        stale: Bool? = nil
    ) {
        self.operation = operation
        self.data = data
        self.error = error
        self.stale = stale
    }
}


/// An error structure describing an error that may have happened in one of the exchanges.
public enum CombinedError: Error {
    
    /// Describes an error that occured on the networking layer.
    case network(URLError)
    
    /// Describes errors that occured during the GraphQL execution.
    case graphql([GraphQLError])
    
    /// An error occured and it's not clear why.
    case unknown(Error)
}

extension CombinedError: Equatable {
    public static func == (lhs: CombinedError, rhs: CombinedError) -> Bool {
        switch (lhs, rhs) {
        case let (.graphql(l), .graphql(r)):
            return l == r
        case let (.network(l), .network(r)):
            return l == r
        default:
            return false
        }
    }
}


extension OperationResult {
    /// Changes the `stale` value fo the operation result on a copy of the current instance.
    func with(stale: Bool) -> OperationResult {
        var copy = self
        copy.stale = stale
        return copy
    }
}

extension OperationResult: Identifiable {
    
    /// Id of the operation related to this result.
    public var id: String {
        self.operation.id
    }
}

/// A structure describing decoded result of an operation execution.
///
/// - NOTE: Decoded result may include errors from invalid data even if
///         the response query was correct.
public struct DecodedOperationResult<T> {
    
    /// Back-reference to the operation that triggered the execution.
    public var operation: Operation
    
    /// Data received from the server.
    public var data: T
    
    /// Execution error encountered in one of the exchanges.
    public var error: CombinedError?
    
    /// Tells wether the result of the query is ot up-to-date.
    public var stale: Bool?
}

