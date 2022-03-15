import Combine
import Foundation
import GraphQL

public class FetchExchange: Exchange {
    
    /// Connection to the server.
    var session: URLSession = .shared
    
    /// Shared decoder that we use to process responses.
    private var decoder = JSONDecoder()
    
    // MARK: - Methods
    
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        let shared = operations.share()
        
        let downstream = shared
            .filter { operation in
                operation.kind != .query && operation.kind != .mutation
            }
            .eraseToAnyPublisher()
        
        let upstream = next(downstream)
        
        let fetchstream = shared
            .filter({ operation in
                operation.kind == .query || operation.kind == .mutation
            })
            .flatMap({ operation in
                self.session.dataTaskPublisher(for: operation.request)
                    .map { (data, response) in
                        OperationResult(
                            operation: operation,
                            data: data,
                            errors: [],
                            stale: false
                        )
                    }
                    .catch { error -> AnyPublisher<OperationResult, Never> in
                        let result = OperationResult(
                            operation: operation,
                            data: nil,
                            errors: [.network(error)],
                            stale: false
                        )
                        
                        return Just(result).eraseToAnyPublisher()
                    }
            })
        
        return fetchstream.merge(with: upstream).eraseToAnyPublisher()
    }

}
