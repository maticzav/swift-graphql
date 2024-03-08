import RxSwift
import Foundation

/// Exchange that composes multiple exchanges into one exchange.
public struct ComposeExchange: Exchange {

    /// All exchanges chained right-to-left.
    private var exchanges: [Exchange]
    
    public init(exchanges: [Exchange]) {
        self.exchanges = exchanges
    }
    
    // MARK: - Methods
    
    public func register(
        client: GraphQLClient,
        operations: Observable<Operation>,
        next: @escaping ExchangeIO
    ) -> Observable<OperationResult> {
        let combined: ExchangeIO = exchanges.reversed().reduce(next) { inner, exchange in
            return { (downstream: Observable<Operation>) -> Observable<OperationResult> in
                return exchange.register(client: client, operations: downstream, next: inner)
            }
        }
        
        return combined(operations)
    }
}
