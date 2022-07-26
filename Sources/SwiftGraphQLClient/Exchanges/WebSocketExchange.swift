import Combine
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
    
    public convenience init(
        request: URLRequest,
        config: GraphQLWebSocketConfiguration = GraphQLWebSocketConfiguration(),
        handleAllOperations: Bool = false
    ) {
        let client = GraphQLWebSocket(request: request, config: config)
        
        self.init(client: client, handleAllOperations: handleAllOperations)
    }
    
    public init(client: GraphQLWebSocket, handleAllOperations: Bool = false) {
        self.client = client
        self.handleAllOperations = handleAllOperations
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
    private func createSubscriptionSource(operation: Operation) -> AnyPublisher<OperationResult, Never> {
        let publisher: AnyPublisher<OperationResult, Never> = self.client.subscribe(operation.args)
            .map { result -> OperationResult in
                if let gqlErrors = result.errors {
                    return OperationResult(operation: operation, data: result.data, errors: [.graphql(gqlErrors)], stale: false)
                }
                
                return OperationResult(operation: operation, data: result.data, errors: [], stale: false)
            }
            .catch { error -> AnyPublisher<OperationResult, Never> in
                switch error {
                case let gqlError as [GraphQLError]:
                    let result = OperationResult(
                        operation: operation,
                        data: AnyCodable(()),
                        errors: [CombinedError.graphql(gqlError)],
                        stale: false
                    )
                    return Just(result).eraseToAnyPublisher()
                default:
                    let result = OperationResult(
                        operation: operation,
                        data: AnyCodable(()),
                        errors: [CombinedError.unknown(error)],
                        stale: false
                    )
                    return Just(result).eraseToAnyPublisher()
                }
                
            }
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    public func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        let shared = operations.share()
        
        // Fowarded operations.
        let downstream = shared
            .filter { !self.shouldHandle(operation: $0) }
            .eraseToAnyPublisher()
        let upstream = next(downstream)
        
        // Handled operations.
        let socketstream = shared
            .filter { self.shouldHandle(operation: $0) }
            .flatMap { operation -> AnyPublisher<OperationResult, Never> in
                let torndown = shared
                    .map { $0.kind == .teardown && $0.id == operation.id }
                    .eraseToAnyPublisher()
                
                return self.createSubscriptionSource(operation: operation)
                    .onEnd {
                        
                        // Once the subscription ends (either because user stopped it
                        // or because the server ended the transmission), we inform
                        // the client-pipeline that it should be dismantled.
                        client.reexecute(operation: operation.with(kind: .teardown))
                    }
                    .takeUntil(torndown)
                    .eraseToAnyPublisher()
            }
            
        return upstream.merge(with: socketstream).eraseToAnyPublisher()
    }
}
#endif
