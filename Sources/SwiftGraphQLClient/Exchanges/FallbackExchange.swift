import Combine
import Foundation
import GraphQL

/// An exchange that doesn't do anything and returns no results.
public struct FallbackExchange: Exchange {
    
    /// Tells whether the exchange should display error messages.
    var debug: Bool
    
    // MARK: - Methods
    
    func register(
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
                    
                    client.log(message: message)
                }
                
                // Filter out all unprocessed operations from the stream.
                return OperationResult?.none
            }
            .eraseToAnyPublisher()
    }
}
