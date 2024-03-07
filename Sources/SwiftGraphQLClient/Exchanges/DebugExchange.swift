import RxSwiftCombine
import Foundation
import GraphQL

/// Exchange that logs operations going down- and results going up-stream.
///
/// - NOTE: `DebugExchange` assumes that the logger level of the client is set to `.debug`. Otherwise, the logs might not appear in the stream.
///
/// ```swift
/// // chaning the client logger level
/// var config = SwiftGraphQLClient.ClientConfiguration()
/// config.logger.logLevel = .debug
///
/// SwiftGraphQLClient.Client(request: request, exchanges: exchanges, config: config)
/// ```
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

