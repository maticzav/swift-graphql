import Foundation

/**
 This file contains code used to download schema from a remote server.
 */

extension GraphQLCodegen {
    /// Downloads a schema from the provided endpoint to the target file path.
    ///
    /// - Parameters:
    ///     - endpoint: The URL of your GraphQL server.
    ///     - handler: Introspection schema handler.
    static func downloadFrom(_ endpoint: URL) throws -> GraphQL.Schema {
        GraphQL.parse(try self.downloadFrom(endpoint))
    }
    
    
    /// Downloads a schema from the provided endpoint to the target file path.
    ///
    /// - Parameters:
    ///     - endpoint: The URL of your GraphQL server.
    ///     - handler: Introspection schema handler.
    static func downloadFrom(_ endpoint: URL) throws -> Data {
        /* Compose a request. */
        var request = URLRequest(url: endpoint)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        let query: [String: Any] = ["query": GraphQL.introspectionQuery]
        
        request.httpBody = try! JSONSerialization.data(
            withJSONObject: query,
            options: JSONSerialization.WritingOptions()
        )
        
        /* Semaphore */
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Data, IntrospectionError>?
        
        /* Load the schema. */
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            /* Check for errors. */
            if let error = error {
                result = .failure(.error(error))
                semaphore.signal()
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                result = .failure(.statusCode)
                semaphore.signal()
                return
            }
            
            /* Save JSON to file. */
            if let data = data {
                result = .success(data)
                semaphore.signal()
                return
            }
        }.resume()
        
        /* Result */
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        default:
            throw IntrospectionError.unknown
        }
    }

}

enum IntrospectionError: Error {
    case error(Error)
    case statusCode
    case unknown
}
