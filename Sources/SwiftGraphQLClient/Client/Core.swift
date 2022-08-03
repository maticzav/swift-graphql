import Combine
import Foundation
import GraphQL
import Logging

/// A built-in implementation of the GraphQLClient specification that may be used with the library.
///
/// - NOTE: SwiftUI bindings and Selection interloop aren't bound to the default implementation.
///         You may use them with a custom implementation as well.
public class Client: GraphQLClient, ObservableObject {
    
    /// Request to use to perform operations.
    public let request: URLRequest
    
    /// A configuration for the client behaviour.
    private let config: ClientConfiguration
    
    // MARK: - Exchange Pipeline
    
    /// The operations stream that lets the client send and listen for them.
    private var operations = PassthroughSubject<Operation, Never>()
    
    /// Stream of results that may be used as the base for sources.
    private var results: AnyPublisher<OperationResult, Never>
    
    // MARK: - Sources
    
    /// Stream of results related to a given operation.
    public typealias Source = AnyPublisher<OperationResult, Never>
    
    /// Map of currently active sources identified by their operation identifier.
    ///
    /// - NOTE: Removing the source from the active list should start its deallocation.
    private var active: [String: Source]
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    /// Creates a new client that processes requests using provided exchanges.
    ///
    /// - parameter exchanges: List of exchanges that process each operation left-to-right.
    ///
    public init(
        request: URLRequest,
        exchanges: [Exchange],
        config: ClientConfiguration = ClientConfiguration()
    ) {
        // A publisher that never emits anything.
        let noop = Empty<OperationResult, Never>().eraseToAnyPublisher()
        
        self.request = request
        self.config = config
        self.results = noop
        self.active = [:]
        
        let operations = operations.share().eraseToAnyPublisher()
        
        // We think of all exchanges as a single flattened exchange - once
        //  we have sent a request through the pipeline there's nothing left to do
        //  and we pass it in the stream of all operations from the client.
        let exchange = ComposeExchange(exchanges: exchanges)
        self.results = exchange
            .register(client: self, operations: operations, next: { _ in noop })
            .share()
            .eraseToAnyPublisher()
        
        // We start the chain to make sure the data is always flowing through the pipeline.
        //  This is important to make sure all exchanges are fully initialised
        //  even if there are no active subscribers yet.
        self.results
            .sink { _ in }
            .store(in: &self.cancellables)
        
        self.config.logger.info("GraphQL Client ready!")
    }
    
    /// Creates a new GraphQL Client using default exchanges, ready to go and be used.
    ///
    /// - NOTE: By default, it includes deduplication exchange, basic caching exchange and the fetch exchange.
    convenience public init(request: URLRequest, config: ClientConfiguration = ClientConfiguration()) {
        let exchanges: [Exchange] = [
            DedupExchange(),
            CacheExchange(),
            FetchExchange()
        ]
        
        self.init(request: request, exchanges: exchanges, config: config)
    }
    
    // MARK: - Core
    
    /// Log a debug message.
    public var logger: Logger {
        self.config.logger
    }
    
    /// Reexecutes an operation by sending it down the exchange pipeline.
    ///
    /// - NOTE: The operation only re-executes if there are any active subscribers
    ///          to the operation's exchange results.
    public func reexecute(operation: Operation) {
        // Check that we have an active subscriber.
        guard operation.kind != .mutation, self.active[operation.id] != nil else {
            self.config.logger.debug("Operation \(operation.id) is no longer active.")
            return
        }
        
        self.config.logger.debug("Reexecuting operation \(operation.id)...")
        self.operations.send(operation)
    }
    
    /// Executes an operation by sending it down the exchange pipeline.
    public func execute(operation: Operation) -> Source {
        self.config.logger.debug("Execution operation \(operation.id)...")
        
        // Mutations shouldn't have open sources because they are executed once and "discarded".
        if operation.kind == .mutation {
            return createResultSource(operation: operation)
        }
        
        let source: Source
        if let existingSource = active[operation.id] {
            source = existingSource
        } else {
            source = createResultSource(operation: operation)
            active[operation.id] = source
        }
        
        // We chain the `receiveOperation` event outside of the `createResultSource`
        // to send a new operation down the exchange chain even if the
        // source already exists.
        //
        // Additionally, we have considered the following cases in deciding how
        // to handle concurrent operations:
        //  - A and B request the same operation at about the same time:
        //      the chain should de-duplicate the second response because it hasn't
        //      received a reply to the first one yet and both sources should receive
        //      the result once server replies.
        //  - A requests an operation, receives the response and then
        //    B requests the same operation:
        //      depending on the request policy, exchanges should either send the cached
        //      response immediately or wait for the result to come back.
        //
        // To sum up both cases, client shouldn't handle processing of the operations.
        return source
            .handleEvents(receiveSubscription: { _ in
                self.operations.send(operation)
            })
            .eraseToAnyPublisher()
    }
    
    /// Returns a new result source that
    private func createResultSource(operation: Operation) -> Source {
        self.config.logger.debug("Creating result source for operation \(operation.id)...")
        
        let source = self.results
            .filter { $0.operation.kind == operation.kind && $0.operation.id == operation.id }
            .eraseToAnyPublisher()
        
        // We aren't interested in composing a full-blown
        // pipeline for mutations because we only get a single result
        // (i.e. the result of the mutation).
        if operation.kind == .mutation {
            return source
                .handleEvents(receiveSubscription: { _ in
                    self.operations.send(operation)
                })
                .first()
                .eraseToAnyPublisher()
        }
        
        // We create a new source that listenes for events until
        // a teardown event is sent through the pipeline. When that
        // happens, we emit a completion event.
        //
        // NOTE: We need the torndown stream because queries and subscriptions
        //  return a stream that keeps updating (e.g. stale result)
        //  and needs to be manually dismantled.
        let torndown = self.operations
            .filter { $0.kind == .teardown && $0.id == operation.id }
            .eraseToAnyPublisher()
        
        let result: AnyPublisher<OperationResult, Never> = source
            .handleEvents(receiveCompletion: { _ in
                // Once the publisher stops the stream (i.e. the stream ended because we
                // received all relevant results), we dismantle the pipeline by sending
                // the teardown event to all exchanges in the chain.
                self.config.logger.debug("Operation \(operation.id) source has completed.")
                
                self.active.removeValue(forKey: operation.id)
                self.operations.send(operation.with(kind: .teardown))
            })
            .map { result -> AnyPublisher<OperationResult, Never> in
                self.config.logger.debug("Processing result of operation \(operation.id)")
                
                // Mark a result as stale when a new operation is sent with the same key.
                guard operation.kind == .query else {
                    return Just(result).eraseToAnyPublisher()
                }
                
                // Mark the current result as `stale` when the client
                // requests a query with the same key again.
                let staleResult: AnyPublisher<OperationResult, Never> = self.operations
                    .filter { $0.kind == .query && $0.id == operation.id && $0.policy != .cacheOnly }
                    .first()
                    .map { operation -> OperationResult in
                        var copy = result
                        copy.stale = true
                        return copy
                    }
                    .eraseToAnyPublisher()
                
                return Just(result).merge(with: staleResult).eraseToAnyPublisher()
            }
            .switchToLatest()
            // NOTE: We use `takeUntil` teardown operator here to emit finished event
            // if the source has finished sending events and requested a teardown.
            // This is necessary to correctly propagate down the completion since the
            // finished event sent by the publisher may have been lost in the pipeline.
            .takeUntil(torndown)
            .handleEvents(receiveCancel: {
                // Once the source has been canceled because the application is no longer interested
                // in results, we start the teardown process.
                self.config.logger.debug("Operation \(operation.id) source has been canceled.")
                
                self.active.removeValue(forKey: operation.id)
                self.operations.send(operation.with(kind: .teardown))
            })
            // NOTE: We create a sharable source because a single source may be
            // reused multiple times for operation with the same identifier
            // but a different subscriber.
            .share()
            .eraseToAnyPublisher()
    
        return result
    }
    
    // MARK: - Querying
    
    /// Executes a query request with given execution parameters.
    public func query(
        _ args: ExecutionArgs,
        request: URLRequest? = nil,
        policy: Operation.Policy = .cacheFirst
    ) -> Source {
        let operation = Operation(
            id: UUID().uuidString,
            kind: .query,
            request: request ?? self.request,
            policy: policy,
            types: [],
            args: args
        )
        
        return self.execute(operation: operation)
    }
    
    /// Executes a mutation request with given execution parameters.
    public func mutate(
        _ args: ExecutionArgs,
        request: URLRequest? = nil,
        policy: Operation.Policy = .cacheFirst
    ) -> Source {
        let operation = Operation(
            id: UUID().uuidString,
            kind: .mutation,
            request: request ?? self.request,
            policy: policy,
            types: [],
            args: args
        )
        
        return self.execute(operation: operation)
    }
    
    /// Executes a subscription request with given execution parameters.
    public func subscribe(
        _ args: ExecutionArgs,
        request: URLRequest? = nil,
        policy: Operation.Policy = .cacheFirst
    ) -> Source {
        let operation = Operation(
            id: UUID().uuidString,
            kind: .subscription,
            request: request ?? self.request,
            policy: policy,
            types: [],
            args: args
        )
        
        return self.execute(operation: operation)
    }
}
