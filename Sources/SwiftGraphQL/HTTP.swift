import Foundation

struct GQLRequestBody: Encodable {
    let query: String
    let variables: [String: Data]
}

/* Client */


public struct GraphQLClient {
    private let endpoint: URL
    
    // MARK: - Initializers
    
    public init(endpoint: URL) {
        self.endpoint = endpoint
    }
    
    public typealias Response<Type, TypeLock> = Result<GraphQLResult<Type, TypeLock>, NetworkError>
    
    public enum NetworkError: Error {
        case network(Error)
        case badCode
    }
    
    // MARK: - Methods
    
    /// Sends a query request to the server.
    public func send<Type>(selection: Selection<Type, RootQuery>, completionHandler: @escaping (Response<Type, RootQuery>) -> Void) -> Void {
        perform(
            operation: .query,
            selection: selection,
            completionHandler: completionHandler
        )
    }
    
    /// Sends a mutation request to the server.
    public func send<Type>(selection: Selection<Type, RootMutation>, completionHandler: @escaping (Response<Type, RootMutation>) -> Void) -> Void {
        perform(
            operation: .mutation,
            selection: selection,
            completionHandler: completionHandler
        )
    }
    
    /* Internals */
    
    public func perform<Type, TypeLock>(
        operation: GraphQLOperationType,
        selection: Selection<Type, TypeLock>,
        completionHandler: @escaping (Response<Type, TypeLock>
    ) -> Void) -> Void where TypeLock: Decodable {
        /* Compose a request. */
        var request = URLRequest(url: endpoint)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        /* Compose body */
        let query = selection.selection.serialize(for: operation)
        var variables = [String: Data]()
        
        for argument in selection.selection.arguments {
            variables[argument.hash] = argument.value
        }
        
        let body = GQLRequestBody(
            query: query,
            variables: variables
        )
        
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .deferredToData
        
        request.httpBody = try! encoder.encode(body)
        
        /* Parse the data and return the result. */
        func onComplete(data: Data?, response: URLResponse?, error: Error?) -> Void {
            /* Check for errors. */
            if let error = error {
                return completionHandler(.failure(.network(error)))
            }
            
//            guard let httpResponse = response as? HTTPURLResponse,
//                (200...299).contains(httpResponse.statusCode) else {
//                return completionHandler(.failure(.badCode))
//            }
            
            /* Serialize received JSON. */
            if let data = data {
                let result = try! GraphQLResult(data, with: selection)
                return completionHandler(.success(result))
            }
        }
        
        /* Kick off the request. */
        URLSession.shared.dataTask(with: request, completionHandler: onComplete).resume()
    }
}

