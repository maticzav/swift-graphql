import Combine
import Foundation
import GraphQL

/// A built-in implementation of the GraphQLClient specification that may be used with the library.
///
/// - NOTE: SwiftUI bindings and Selection interloop aren't bound to the default implementation.
///         You may use them with a custom implementation as well.
public class Client: GraphQLClient, ObservableObject {
    
    // MARK: - Exchange Pipeline
    
    /// The operations stream that lets the client send and listen for them.
    private var operations = PassthroughSubject<Operation, Never>()
    
    /// Stream of results that may be used as the base for sources.
    private var results: AnyPublisher<OperationResult, Never>
    
    // MARK: - Sources
    
    /// Stream of results related to a given operation.
    public typealias Source = AnyPublisher<OperationResult, Never>
    
    /// Map of currently active sources identified by their operation identifier.
    private var active: [String: Source]
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    /// Creates a new client that processes requests using provided exchanges.
    ///
    /// - parameter exchanges: List of exchanges that process each operation left-to-right.
    ///
    init(exchanges: [Exchange]) {
        let exchange = ComposeExchange(exchanges: exchanges)
        let operations = operations.share().eraseToAnyPublisher()
        
        let noop = Empty<OperationResult, Never>().eraseToAnyPublisher()
        self.results = noop
        
        self.active = [:]
        
        self.results = exchange.register(
            client: self,
            operations: operations,
            next: { _ in noop }
        )
        
        // We start the chain to make sure the data is always flowing through the pipeline.
        // This is important to make sure all exchanges receive information when necessary
        // even if there are no active subscribers outside the client.
        self.results
            .sink { _ in }
            .store(in: &self.cancellables)
    }
    
    /// Creates a new GraphQL Client using default exchanges, ready to go and be used.
    convenience init() {
        let exchanges: [Exchange] = [
            DedupExchange(),
            CacheExchange(),
            FetchExchange()
        ]
        
        self.init(exchanges: exchanges)
    }
    
    // MARK: - Methods
    
    /// Log a debug message.
    public func log(message: String) {
        print(message)
    }
    
    /// Reexecutes an operation by sending it down the exchange pipeline.
    ///
    /// - NOTE: The operation only re-executes if there are any active subscribers
    ///          to the operation's exchange results.
    public func reexecute(operation: Operation) {
        // Check that we have an active subscriber.
        guard operation.kind == .mutation && self.active[operation.id] != nil else {
            return
        }
        
        self.operations.send(operation)
    }
    
    /// Executes an operation by sending it down the exchange pipeline.
    public func execute(operation: Operation) -> Source {
        
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
        
        // We chain the `onStart` operator outside of the `createResultSource`
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
            .onStart {
                self.operations.send(operation)
            }
            .eraseToAnyPublisher()
    }
    
    /// Defines how result streams are created.
    private func createResultSource(operation: Operation) -> Source {
        let source = self.results
            .filter { $0.operation.kind == operation.kind && $0.operation.id == operation.id }
            .eraseToAnyPublisher()
        
        // We aren't interested in composing a full-blown
        // pipeline for mutations because we only get a single result
        // (i.e. the result of the mutation).
        if operation.kind == .mutation {
            return source
                .onStart {
                    self.operations.send(operation)
                }
                .first()
                .eraseToAnyPublisher()
        }
        
        // We create a new source that listenes for events until
        // a teardown event is sent through the pipeline. When that
        // happens, we emit a completion event.
        let torndown = self.operations
            .map { $0.kind == .teardown && $0.id == operation.id }
            .eraseToAnyPublisher()
        
        let result: AnyPublisher<OperationResult, Never> = source
            .takeUntil(torndown)
            .map { result -> AnyPublisher<OperationResult, Never> in
                // Mark a result as stale when a new operation is sent with the same key.
                guard operation.kind == .query else {
                    return Just(result).eraseToAnyPublisher()
                }
                
                // Mark the result as `stale` when a request with the same
                // key is emitted down the chain.
                let staleResult: AnyPublisher<OperationResult, Never> = self.operations
                    .filter { $0.kind == .query && $0.id == operation.id && $0.policy != .cacheOnly }
                    .first()
                    .map { operation -> OperationResult in
                        var copy = result
                        copy.stale = true
                        return copy
                    }
                    .eraseToAnyPublisher()
                
                return staleResult
            }
            .switchToLatest()
            .onEnd {
                // Once the publisher stops the stream (i.e. the stream ended because we
                // received all relevant results), we dismantle the pipeline by sending
                // the teardown event to all exchanges in the chain.
                self.active.removeValue(forKey: operation.id)
                self.operations.send(operation.with(kind: .teardown))
            }
            .eraseToAnyPublisher()
    
        return result
    }
}
