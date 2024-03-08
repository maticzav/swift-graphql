import RxSwiftCombine
import Foundation
import GraphQL

/// Exchange that lets you modify `extensions` property of the operation.
///
/// You should place this exchange before the asynchronous exchanges that perform requests
/// (e.g. `FetchExchange`) so that the opeartion is modified before being sent.
public struct ExtensionsExchange: Exchange {
    
    /// Getter function called to get the extensions of an operation.
    private var getExtensions: (Operation) -> [String: AnyCodable]?
    
    public init(_ getExtensions: @escaping (Operation) -> [String: AnyCodable]?) {
        self.getExtensions = getExtensions
    }
    
    // MARK: - Methods
    
    public func register(
        client: GraphQLClient,
        operations: Observable<Operation>,
        next: @escaping ExchangeIO
    ) -> Observable<OperationResult> {
        let downstream = operations
            .map { operation -> Operation in
                guard let extensions = self.getExtensions(operation) else {
                    return operation
                }
                
                var copy = operation
                copy.args.extensions = extensions
                return copy
            }
        
        return next(downstream)
    }
}
