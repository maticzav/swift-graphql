import Foundation

import Combine
import Foundation
import GraphQL

/// Exchange that lets you perform GraphQL subscription queries.
public class SubscriptionExchange: Exchange {
    
    
    
    // MARK: - Methods
    
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        Empty<OperationResult, Never>().eraseToAnyPublisher()
    }
}

