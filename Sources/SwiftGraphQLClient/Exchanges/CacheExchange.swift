import Combine
import Foundation

/// Cache exchange uses document caching to invalidate results.
/// When a mutation operation
struct CacheExchange: Exchange {
    
    /// Results from previous oeprations indexed by operation's ids.
    private var cache: [String: OperationResult]
    
    init() {
        self.cache = [:]
    }
    
    /// Tells whether a given operation should rely on the result saved in the cache.
    func shouldUseCache(operation: Operation) -> Bool {
        operation.kind == .query &&
        operation.policy != .networkOnly &&
        (operation.policy == .cacheOnly || cache[operation.id] != nil)
    }
    
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: @escaping ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        let shared = operations.share()
        
        shared
            .filter { $0.kind == .query || $0.kind == .mutation }
            .map { operation in
                
            }
        
        return next(operations)
    }
}

private extension Operation {
    /// Returns a new operation that has a modified policy.
    func with(policy: Operation.Policy) -> Operation {
        var copy = self
        copy.policy = policy
        return copy
    }
}
