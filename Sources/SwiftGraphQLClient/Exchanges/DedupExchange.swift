import Foundation

import Combine
import Foundation
import GraphQL

/// Exchange that prevents multiple executions of the same operation.
public class DedupExchange: Exchange {
    
    // MARK: - Methods
    
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        Empty<OperationResult, Never>().eraseToAnyPublisher()
    }
}

