import Combine
import Foundation
import GraphQL

/// Exchange that logs operations going down- and results going up-stream.
public struct DebugExchange: Exchange {
    
    /// Tells whether the client is in a development environment of not.
    private var debug: Bool

    /// Optional custom logging function.
    private var logger: ((String) -> Void)?

    public init(
        debug: Bool = true, 
        logger: ((String) -> Void)? = nil
    ) {
        self.debug = debug
        self.logger = logger
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

        // Function used to emit logs.
        let log = self.logger ?? client.log
        
        let downstream = operations
            .handleEvents(receiveOutput: { operation in
                log("[debug exchange]: Incoming Operation: \(operation)")
            })
            .eraseToAnyPublisher()
        
        let upstream = next(downstream)
            .handleEvents(receiveOutput: { result in
                log("[debug exchange]: Completed Operation: \(result)")
            })
            .eraseToAnyPublisher()
        
        return upstream
    }
}

