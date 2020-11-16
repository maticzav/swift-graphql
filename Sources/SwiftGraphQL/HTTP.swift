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
    public static func send<Type, TypeLock>(
        _ selection: Selection<Type, TypeLock?>,
        /// Server endpoint URL.
        to endpoint: String,
        /// A dictionary of key-value header pairs.
        headers: HttpHeaders = [:],
        /// Method to use. (Default to POST).
        method: HttpMethod = .post,
        onComplete completionHandler: @escaping (Response<Type, TypeLock>) -> Void
    ) -> Void where TypeLock: GraphQLOperation & Decodable {
        perform(
            selection: selection,
            operation: TypeLock.operation,
            endpoint: endpoint,
            method: method,
            headers: headers,
            completionHandler: completionHandler
        )
    }
    
    /// Sends a query request to the server.
    ///
    /// - Note: This is a shortcut function for when you are expecting the result.
    ///         The only difference between this one and the other one is that you may select
    ///         on non-nullable TypeLock instead of a nullable one.
    public static func send<Type, TypeLock>(
        _ selection: Selection<Type, TypeLock>,
        /// Server endpoint URL.
        to endpoint: String,
        /// A dictionary of key-value header pairs.
        headers: HttpHeaders = [:],
        /// Method to use. (Default to POST).
        method: HttpMethod = .post,
        onComplete completionHandler: @escaping (Response<Type, TypeLock>) -> Void
    ) -> Void where TypeLock: GraphQLOperation & Decodable {
        perform(
            selection: selection.nonNullOrFail,
            operation: TypeLock.operation,
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
        case badpayload
        case badstatus
    }
    
    public enum HttpMethod: String, Equatable {
        case get = "GET"
        case post = "POST"
    }
    
    public typealias Response<Type, TypeLock> = Result<GraphQLResult<Type, TypeLock>, HttpError>
    
    public typealias HttpHeaders = [String: String]
    
    // MARK: - Private helpers
    
    private static func perform<Type, TypeLock>(
        selection: Selection<Type, TypeLock?>,
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
            
            return completionHandler(.failure(.badpayload))
        }
        
        // Construct a session.
        URLSession.shared.dataTask(with: request, completionHandler: onComplete).resume()
    }
}

extension SwiftGraphQL.HttpError: Equatable {
    public static func == (lhs: SwiftGraphQL.HttpError, rhs: SwiftGraphQL.HttpError) -> Bool {
        
        // Equals if they are of the same type, different otherwise.
        switch (lhs, rhs) {
        case (.badURL, badURL),
             (.timeout, .timeout),
             (.badpayload, .badpayload),
             (.badstatus, .badstatus):
            return true
        default:
            return false
        }
    }
}
