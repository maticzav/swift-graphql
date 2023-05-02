import Combine
import Foundation

/// An exchange that lets you listen to errors happening in the execution pipeline.
public struct ErrorExchange: Exchange {
    
    /// Callback function that the exchange calls for every error in the operation result.
    private var onError: (CombinedError, Operation) -> Void
    
    public init(onError: @escaping (CombinedError, Operation) -> Void) {
        self.onError = onError
    }
    
    // MARK: - Methods
    
    public func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: @escaping ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        next(operations)
            .handleEvents(receiveOutput: { result in
                if let error = result.error {
                    self.onError(error, result.operation)
                }
            })
            .eraseToAnyPublisher()
    }
}
