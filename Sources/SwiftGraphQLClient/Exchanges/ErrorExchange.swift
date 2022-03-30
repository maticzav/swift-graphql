import Combine
import Foundation

/// An exchange that lets you listen to errors happening in the execution pipeline.
struct ErrorExchange: Exchange {
    
    /// Error event handler.
    private var onError: (CombinedError, Operation) -> Void
    
    init(onError: @escaping (CombinedError, Operation) -> Void) {
        self.onError = onError
    }
    
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: @escaping ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        next(operations)
            .onPush { result in
                for error in result.errors {
                    self.onError(error, result.operation)
                }
            }
            .eraseToAnyPublisher()
    }
}
