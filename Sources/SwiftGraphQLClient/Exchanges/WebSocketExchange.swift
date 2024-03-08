import RxSwift
import Foundation
import GraphQL

#if canImport(GraphQLWebSocket)
import GraphQLWebSocket

/// Exchange that lets you perform GraphQL queries over WebSocket protocol.
///
/// - NOTE: By default WebSocketExchange only handles subscription operations
///         but you may configure it to handle all operations equally.
public class WebSocketExchange: Exchange {
    
    /// Reference to the client that actually establishes the WebSocket connection with the server.
    private var client: GraphQLWebSocket
    
    /// Tells whether the exchange should handle query and mutation operations as well as subscriptions.
    private var handleAllOperations: Bool = false
    
    /// Subscriptions that are currently active identified by their operation IDs.
    private var sources: [String: DisposeBag]
    
    // MARK: - Initializers
    
    public init(client: GraphQLWebSocket, handleAllOperations: Bool = false) {
        self.client = client
        self.handleAllOperations = handleAllOperations
        self.sources = [:]
    }
    
    public convenience init(
        request: URLRequest,
        config: GraphQLWebSocketConfiguration = GraphQLWebSocketConfiguration(),
        handleAllOperations: Bool = false
    ) {
        let client = GraphQLWebSocket(request: request, config: config)
        self.init(client: client, handleAllOperations: handleAllOperations)
    }
    
    // MARK: - Methods
    
    /// Considers the configuration of the exchange and tells whether this exchange
    /// should handle a given oepration.
    private func shouldHandle(operation: Operation) -> Bool {
        switch operation.kind {
        case .subscription:
            return true
        case .query, .mutation:
            return self.handleAllOperations
        case .teardown:
            return false
        }
    }
    
    /// Creates a new stream of events related to the given operation.
    private func createSubscriptionSource(operation: Operation) -> Observable<OperationResult> {
        let publisher: Observable<OperationResult> = self.client
            .subscribe(operation.args)
            .map { exec -> OperationResult in
                var op = OperationResult(
                    operation: operation,
                    data: exec.data,
                    error: nil,
                    stale: false
                )
                
                if let errors = exec.errors {
                    op.error = .graphql(errors)
                }
                return op
            }
        
        return publisher
    }
    
    public func register(
        client: GraphQLClient,
        operations: Observable<Operation>,
        next: ExchangeIO
    ) -> Observable<OperationResult> {
        let shared = operations.share()
        
        // Fowarded operations.
        let downstream = shared
            .filter { !self.shouldHandle(operation: $0) }
        let upstream = next(downstream)
        
        // Handled operations.
        let socketstream = shared
            .filter { self.shouldHandle(operation: $0) }
            .flatMap { operation -> Observable<OperationResult> in
                let torndown = shared
                    .filter { $0.kind == .teardown && $0.id == operation.id }
                
                return self.createSubscriptionSource(operation: operation)
                    .do(onCompleted: {
                        // Once the subscription ends because socket stream stopped sending events,
                        // we inform the client-pipeline that it should be dismantled.
                        client.reexecute(operation: operation.with(kind: .teardown))
                    })
                    // NOTE: We use `takeuntil` to clear up initialised source when
                    // the client (i.e. application) emits the teardown event because someone
                    // cancelled the subscription.
                    .takeUntil(torndown)
            }
            
        return Observable.merge(upstream, socketstream)
    }
}
#endif
