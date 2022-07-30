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
    func dataTaskPublisher(for: URLRequest, with: Data) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
    
}

extension URLSession: FetchSession {
    public func dataTaskPublisher(
        for request: URLRequest,
        with body: Data
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        var gqlrequest = request
        
        gqlrequest.httpMethod = "POST"
        gqlrequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        gqlrequest.httpBody = body
        
        let publisher: DataTaskPublisher = self.dataTaskPublisher(for: gqlrequest)
        return publisher.eraseToAnyPublisher()
    }
}

/// Performs query and mutation operations on the network.
public class FetchExchange: Exchange {
    
    /// Structure used to connect to the server.
    private var session: FetchSession
    
    /// Shared decoder that's used to decode server responses.
    private var decoder: JSONDecoder
    
    /// Shared encoder that's used to encode request body.
    private var encoder: JSONEncoder
    
    // MARK: - Initializer
    
    public init(
        session: FetchSession = URLSession.shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
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
            .flatMap({ operation -> AnyPublisher<OperationResult, Never> in
                let body = try! self.encoder.encode(operation.args)
                
                let publisher = self.session
                    .dataTaskPublisher(for: operation.request, with: body)
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
                    .eraseToAnyPublisher()
                
                return publisher
            })
        
        return fetchstream.merge(with: upstream).eraseToAnyPublisher()
    }

}
