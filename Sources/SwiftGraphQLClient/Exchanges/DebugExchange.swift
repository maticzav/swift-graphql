import Combine
import Foundation
import GraphQL

/// Exchange that logs operations going down- and results going upstream.
public struct DebugExchange: Exchange {
    
    /// Tells whether the client is in a development environment of not.
    public var debug: Bool
    
    public func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        guard debug else {
            return next(operations)
        }
        
        let downstream = operations
            .onPush({ operation in
                client.log(message: "[Debug Exchange]: Incoming Operation: \(operation)")
            })
            .eraseToAnyPublisher()
        
        let upstream = next(downstream)
            .onPush { result in
                client.log(message: "[Debug Exchange]: Completed Operation: \(result)")
            }
            .eraseToAnyPublisher()
        
        return upstream
    }
}

