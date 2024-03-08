import RxSwiftCombine
import Foundation
import GraphQL

/// An exchange that doesn't do anything and returns no results.
public struct FallbackExchange: Exchange {
    
    /// Tells whether the exchange should display error messages.
    private var debug: Bool

    public init(debug: Bool = true) {
        self.debug = debug
    }
    
    // MARK: - Methods
    
    public func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        operations
            .compactMap { operation -> OperationResult? in
                if operation.kind != .teardown && debug {
                    let message = """
                        No exchange has handled operations of kind "\(operation.kind)". \
                        Check whether you've added an exchange responsible for these operations.
                        """
                    
                    client.logger.debug("\(message)")
                }
                
                // Filter out all unprocessed operations from the stream.
                return OperationResult?.none
            }
    }
}
