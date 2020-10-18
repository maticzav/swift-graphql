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
    static func downloadFrom(_ endpoint: URL, handler: @escaping (GraphQL.Schema) -> Void) {
        self.downloadFrom(endpoint) { (data: Data) -> Void in handler(GraphQL.parse(data)) }
    }
    
    
    /// Downloads a schema from the provided endpoint to the target file path.
    ///
    /// - Parameters:
    ///     - endpoint: The URL of your GraphQL server.
    ///     - handler: Introspection schema handler.
    static func downloadFrom(_ endpoint: URL, handler: @escaping (Data) -> Void) -> Void {
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
        
        /* Load the schema. */
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            /* Check for errors. */
            if let _ = error {
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return
            }
            
            /* Save JSON to file. */
            if let data = data {
                handler(data)
            }
        }
        
        task.resume()
    }

}
