import Foundation

/*
    Contains types used to annotate top-level queries which can be
    built up using generated functions.
*/

public enum Operation {
    public enum Query {}
    public enum Mutation {}
    public enum Subscription {}
}

public typealias RootQuery = Operation.Query
public typealias RootMutation = Operation.Mutation
public typealias RootSubscription = Operation.Subscription


/* Client */


public struct GraphQLClient {
    private let endpoint: URL
    
    // MARK: - Initializers
    
    init(endpoint: URL) {
        self.endpoint = endpoint
    }
    
    public typealias Response<Type> = Result<GraphQLResult<Type>, NetworkError>
    
    public enum NetworkError: Error {
        case network(Error)
        case badCode
    }
    
    // MARK: - Methods
    
    /// Sends a query request to the server.
    public func send<Type>(selection: Selection<Type, RootQuery>, completionHandler: @escaping (Response<Type>) -> Void) -> Void {
        perform(selection: selection, completionHandler: completionHandler)
    }
    
    /// Sends a mutation request to the server.
    public func send<Type>(selection: Selection<Type, RootMutation>, completionHandler: @escaping (Response<Type>) -> Void) -> Void {
        perform(selection: selection, completionHandler: completionHandler)
    }
    
    /* Internals */
    
    private func perform<Type, TypeLock>(
        selection: Selection<Type, TypeLock>,
        completionHandler: @escaping (Response<Type>
    ) -> Void) -> Void {
        /* Compose a request. */
        var request = URLRequest(url: endpoint)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let query: [String: Any] = [
            "query": selection.selection.serialize(for: .query)
        ]
        
        request.httpBody = try! JSONSerialization.data(
            withJSONObject: query,
            options: JSONSerialization.WritingOptions()
        )
        
        /* Parse the data and return the result. */
        func onComplete(data: Data?, response: URLResponse?, error: Error?) -> Void {
            /* Check for errors. */
            if let error = error {
                return completionHandler(.failure(.network(error)))
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                return completionHandler(.failure(.badCode))
            }
            
            // TODO: reread spec on how data and errors are formatted.
            /* Serialize received JSON. */
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let data = json["data"] as? JSONData
                let errors = json["errors"] as? [GraphQLError]
                
                /* Process the GraphQL repsonse. */
                let response = GraphQLResponse(data: data, errors: errors).parse(with: selection)
                
                return completionHandler(.success(response))
            }
        }
        
        /* Kick off the request. */
        URLSession.shared.dataTask(with: request, completionHandler: onComplete).resume()
    }
}

