import Combine
import Foundation
import GraphQL

/// Exchange that logs operations going down- and results going up-stream.
public struct DebugExchange: Exchange {
    
    /// Tells whether the client is in a development environment of not.
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
        guard debug else {
            return next(operations)
        }
        
        let downstream = operations
            .handleEvents(receiveOutput: { operation in
                client.logger.debug("[debug exchange]: Incoming Operation: \(operation)")
            })
            .eraseToAnyPublisher()
        
        let upstream = next(downstream)
            .handleEvents(receiveOutput: { result in
                client.logger.debug("[debug exchange]: Completed Operation: \(result)")
            })
            .eraseToAnyPublisher()
        
        return upstream
    }
}

