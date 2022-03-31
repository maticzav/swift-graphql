import Combine
import Foundation

/// Exchange that lets you naively cache GraphQL resutls of your queries.
///
/// Cache exchange uses document caching to invalidate results. That means that
/// when a mutation result with a return type T goes through the cache exchange,
/// cache exchange invalidates all cached queries that contain a result of type T.
///
/// - NOTE: Cache exchange doesn't perform any deduplication of requests.
///
/// - NOTE: The caching pattern used here is greedy and not optimal.
class CacheExchange: Exchange {
    
    /// Results from previous oeprations indexed by operation's ids.
    private var resultCache: [String: OperationResult]
    
    /// A map that indexes operations related to a given typename.
    private var operationCache: [String: Set<String>]
    
    init() {
        self.resultCache = [:]
        self.operationCache = [:]
    }
    
    /// Tells whether a given operation should rely on the result saved in the cache.
    ///
    /// - NOTE: CacheOnly operations might get a nil value and fail when selection tries
    ///         to decode them. That's O.K.
    func shouldUseCache(operation: Operation) -> Bool {
        operation.kind == .query &&
        operation.policy != .networkOnly &&
        (operation.policy == .cacheOnly || resultCache[operation.id] != nil)
    }
    
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: @escaping ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        let shared = operations.share()
        
        // We synchronously send cached results upstream.
        let cachedOps: AnyPublisher<OperationResult, Never> = shared
            .compactMap { operation in
                guard self.shouldUseCache(operation: operation) else {
                    return nil
                }
                
                let cachedResult = self.resultCache[operation.id]
                if operation.policy == .cacheAndNetwork {
                    return cachedResult?.with(stale: true)
                }
                return cachedResult
            }
            .eraseToAnyPublisher()
        
        // We filter requests that hit cache and listen for results
        // to keep track of received results.
        let downstream = shared
            .filter({ operation in
                // Cache stops cache-only operations - they shouldn't reach any
                // other exchange for obvious reasons.
                guard operation.policy != .cacheOnly else {
                    return false
                }
                
                // We only cache queries and ignore all other kinds of transactions.
                guard operation.kind == .query else {
                    return true
                }
                
                // Filter out cache-first requests that were matched/hit.
                let wasHit = operation.policy == .cacheFirst && self.resultCache[operation.id] != nil
                return operation.policy != .cacheFirst || !wasHit
            })
            .eraseToAnyPublisher()
        
        let forwardedOps: AnyPublisher<OperationResult, Never> = next(downstream)
        
        let upstream = forwardedOps
            .onPush { result in
                
                // Invalidate the cache given a mutation's response.
                if result.operation.kind == .mutation {
                    var pendingOperations = Set<String>()
                    
                    for typename in result.operation.types {
                        guard let cachedOperations = self.operationCache[typename] else {
                            continue
                        }
                        cachedOperations.forEach { pendingOperations.insert($0) }
                    }
                    
                    pendingOperations.forEach { opid in
                        guard let cachedResult = self.resultCache[opid] else {
                            return
                        }
                        
                        self.resultCache.removeValue(forKey: opid)
                        client.reexecute(operation: cachedResult.operation.with(policy: .networkOnly))
                    }
                }
                
                // Caches the result and operation references.
                if let _ = result.data, result.operation.kind == .query {
                    self.resultCache[result.operation.id] = result
                    
                    // NOTE: CacheOnly operations never receive data from the
                    //       exchanges coming after the cache meaning they are
                    //       never indexed for re-execution.
                    for typename in result.operation.types {
                        if self.operationCache[typename] == nil {
                            self.operationCache[typename] = Set<String>()
                        }
                        
                        self.operationCache[typename]!.insert(result.operation.id)
                    }
                }
            }
            .eraseToAnyPublisher()
        
        
        return cachedOps.merge(with: upstream).eraseToAnyPublisher()
    }
}
