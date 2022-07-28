import Combine
import Foundation
import GraphQL

/// Protocol that outlines methods that are required by fetch exchange to operate as expected.
public protocol FetchSession {
    
    /// Returns a publisher that wraps a URL session data task for a given URL request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: The URL request for which to create a data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    func dataTaskPublisher(for request: URLRequest, with args: ExecutionArgs) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
    
}

extension URLSession: FetchSession {
    private static let encoder = JSONEncoder()
    
    public func dataTaskPublisher(for request: URLRequest, with args: ExecutionArgs) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        var gqlrequest = request
        
        gqlrequest.httpMethod = "POST"
        gqlrequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        gqlrequest.httpBody = try! URLSession.encoder.encode(args)
        
        let publisher: DataTaskPublisher = self.dataTaskPublisher(for: gqlrequest)
        return publisher.eraseToAnyPublisher()
    }
}

/// Performs query and mutation operations on the network.
public class FetchExchange: Exchange {
    
    /// Structure used to connect to the server.
    private var session: FetchSession
    
    /// Shared decoder that we use to process responses.
    private var decoder = JSONDecoder()
    
    // MARK: - Initializer
    
    public init(session: FetchSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Methods
    
    public func register(
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
                self.session.dataTaskPublisher(for: operation.request, with: operation.args)
                    .map { (data, response) -> OperationResult in
                        do {
                            let result = try self.decoder.decode(ExecutionResult.self, from: data)
                            
                            if let errors = result.errors {
                                return OperationResult(
                                    operation: operation,
                                    data: result.data,
                                    errors: [.graphql(errors)],
                                    stale: false
                                )
                            }
                            
                            return OperationResult(operation: operation, data: result.data, errors: [], stale: false)
                        } catch(let err) {
                            return OperationResult(
                                operation: operation,
                                data: AnyCodable(()),
                                errors: [.parsing(err)],
                                stale: false
                            )
                        }
                    }
                    .catch { (error: URLError) -> AnyPublisher<OperationResult, Never> in
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
