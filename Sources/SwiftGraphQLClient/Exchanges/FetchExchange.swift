import RxSwift
import Foundation
import GraphQL

/// Protocol that outlines methods that are required by FetchExchange to operate as expected.
///
/// To use a custom HTTP client to send query and mutation opeartion requests extend your client
/// instance to conform to this protocol and pass it in as a `session` parameter to the exchange.
public protocol FetchSession {
    
    /// Returns a publisher that wraps a URL session data task for a given URL request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: The URL request for which to create a data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    func dataTaskPublisher(for: URLRequest, with: Data) -> Observable<(data: Data, response: URLResponse)>
}

/// Exchange that performs query and mutation operations following the [GraphQL over HTTP](https://github.com/graphql/graphql-over-http/blob/main/spec/GraphQLOverHTTP.md) spec.
///
/// FetchExchange should be put at the end of the exchange pipeline. It filters out query and mutation operations
/// that it's processing and doesn't forward them to the next exchange in the pipeline chain.
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
        operations: Observable<Operation>,
        next: ExchangeIO
    ) -> Observable<OperationResult> {
        let shared = operations.share()
        
        let downstream = shared
            .filter { operation in
                operation.kind != .query && operation.kind != .mutation
            }
        
        let upstream = next(downstream)
        
        let fetchstream: Observable<OperationResult> = shared
            .filter({ $0.kind == .query || $0.kind == .mutation })
            .flatMap({ operation -> Observable<OperationResult> in
                let body = try! self.encoder.encode(operation.args)
                
                let torndown = shared
                    .filter { $0.kind == .teardown && $0.id == operation.id }
                
                let publisher: Observable<OperationResult> = self.session
                    .dataTaskPublisher(for: operation.request, with: body)
                    // NOTE: If the client emits the teardown event, we want to clear up
                    //  the initialised source to prevent memory laeks.
                    .takeUntil(torndown)
                    // NOTE: Unlike WebSocketExchange that emits completion when the stream is over,
                    //  fetch response send completion once it has received all the data. Cancelling
                    //  the pipeline then, would prevent updates from exchange in the future, that's
                    //  why we don't cancel it.
                    .map { (data, response) -> OperationResult in
                        do {
                            let result = try self.decoder.decode(ExecutionResult.self, from: data)
                            
                            if let errors = result.errors {
                                return OperationResult(
                                    operation: operation,
                                    data: result.data,
                                    error: .graphql(errors),
                                    stale: false
                                )
                            }
                            
                            return OperationResult(
                                operation: operation,
                                data: result.data,
                                error: nil,
                                stale: false
                            )
                        } catch(let err) {
                            return OperationResult(
                                operation: operation,
                                data: AnyCodable(()),
                                error: .unknown(err),
                                stale: false
                            )
                        }
                    }
                    .catch { (error: Error) -> Observable<OperationResult> in
                        let error: CombinedError = if let error = error as? URLError { .network(error) } else { .unknown(error) }

                        let result = OperationResult(
                            operation: operation,
                            data: nil,
                            error: error,
                            stale: false
                        )
                        
                        return Observable.just(result)
                    }
                
                return publisher
            })

        return Observable.merge(fetchstream, upstream)
    }

}

extension URLSession: FetchSession {
    public func dataTaskPublisher(
        for request: URLRequest,
        with body: Data
    ) -> Observable<(data: Data, response: URLResponse)> {
        var gqlrequest = request
        
        gqlrequest.httpMethod = "POST"
        gqlrequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        gqlrequest.httpBody = body
        
        return Observable<(data: Data, response: URLResponse)>.create({ observer in
            self.dataTask(with: gqlrequest, completionHandler: { data, response, error in
                if let error {
                    observer.onError(error)
                } else if let data, let response {
                    observer.onNext((data, response))
                } else {
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }
}
