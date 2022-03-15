import Combine
import Foundation

/// Exchange that composes multiple exchanges into one exchange.
public struct ComposeExchange: Exchange {

    /// All exchanges chained right-to-left.
    var exchanges: [Exchange]
    
    // MARK: - Methods
    
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: @escaping ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        let combined: ExchangeIO = exchanges.reversed().reduce(next) { inner, exchange in
            return { (downstream: AnyPublisher<Operation, Never>) -> AnyPublisher<OperationResult, Never> in
                return exchange.register(client: client, operations: downstream, next: inner)
            }
        }
        
        return combined(operations)
    }
}
