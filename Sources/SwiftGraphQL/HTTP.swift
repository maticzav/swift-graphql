import Foundation

/*
    Contains types used to annotate top-level queries which can be
    built up using generated functions.
*/

public enum Operation {
    public struct Query: Decodable {}
    public struct Mutation: Decodable {}
    public struct Subscription: Decodable {}
}

public typealias RootQuery = Operation.Query
public typealias RootMutation = Operation.Mutation
public typealias RootSubscription = Operation.Subscription


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
        let body: [String: Any] = [
            "query": query,
        ]
        
        request.httpBody = try! JSONSerialization.data(
            withJSONObject: body,
            options: JSONSerialization.WritingOptions()
        )
        
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

