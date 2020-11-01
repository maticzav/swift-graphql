import Foundation

/*
 SwiftGraphQL has no client as it needs no state. Developers
 should take care of caching and other implementation themselves.
 
 The following code defines a SwiftGraphQL namespace and exposes functions
 that developers can use to execute queries against their server.
 */

public struct SwiftGraphQL {
    // MARK: - Public Methods
    
    /// Sends a query request to the server.
    public static func send<Type, RootQuery>(
        _ selection: Selection<Type, RootQuery>,
        /// Server endpoint URL.
        to endpoint: String,
        /// A dictionary of key-value header pairs.
        headers: HttpHeaders = [:],
        /// Method to use. (Default to POST).
        method: HttpMethod = .post,
        onComplete completionHandler: @escaping (Response<Type, RootQuery>) -> Void
    ) -> Void where RootQuery: GraphQLRootQuery & Decodable {
        perform(
            selection: selection,
            operation: .query,
            endpoint: endpoint,
            method: method,
            headers: headers,
            completionHandler: completionHandler
        )
    }
    
    /// Sends a mutation request to the server.
    public static func send<Type, RootMutation>(
        _ selection: Selection<Type, RootMutation>,
        /// Server endpoint URL.
        to endpoint: String,
        /// A dictionary of key-value header pairs.
        headers: HttpHeaders = [:],
        /// Method to use. (Default to POST).
        method: HttpMethod = .post,
        onComplete completionHandler: @escaping (Response<Type, RootMutation>) -> Void
    ) -> Void where RootMutation: GraphQLRootMutation & Decodable {
        perform(
            selection: selection,
            operation: .mutation,
            endpoint: endpoint,
            method: method,
            headers: headers,
            completionHandler: completionHandler
        )
    }
    
    /// Represents an error of the actual request.
    public enum HttpError: Error {
        case badURL
        case timeout
        case network(Error)
        case badpayload(Error)
        case badstatus
    }
    
    public enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    public typealias Response<Type, TypeLock> = Result<GraphQLResult<Type, TypeLock>, HttpError>
    
    public typealias HttpHeaders = [String: String]
    
    // MARK: - Private helpers
    
    private static func perform<Type, TypeLock>(
        selection: Selection<Type, TypeLock>,
        operation: GraphQLOperationType,
        endpoint: String,
        method: HttpMethod,
        headers: HttpHeaders,
        completionHandler: @escaping (Response<Type, TypeLock>) -> Void
    ) -> Void where TypeLock: Decodable {
        
        // Construct a URL from string.
        guard let url = URL(string: endpoint) else {
            return completionHandler(.failure(.badURL))
        }
        
        // Construct a request.
        var request = URLRequest(url: url)
        
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        
        
        // Compose a query.
        let query = selection.selection.serialize(for: operation)
        var variables = [String: NSObject]()
        
        for argument in selection.selection.arguments {
            variables[argument.hash] = argument.value
        }
        
        let body: Any = [
            "query": query,
            "variables": variables
        ]
        
        let httpBody = try! JSONSerialization.data(
            withJSONObject: body,
            options: JSONSerialization.WritingOptions()
        )
        request.httpBody = httpBody
        
        // Create a completion handler.
        func onComplete(data: Data?, response: URLResponse?, error: Error?) -> Void {
            
            /* Process the response. */
            // Check for HTTP errors.
            if let error = error {
                return completionHandler(.failure(.network(error)))
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                return completionHandler(.failure(.badstatus))
            }
            
            // Try to serialize the response.
            if let data = data, let result = try? GraphQLResult(data, with: selection) {
                return completionHandler(.success(result))
            }
            
            
        }
        
        // Construct a session.
        URLSession.shared.dataTask(with: request, completionHandler: onComplete).resume()
    }
}

