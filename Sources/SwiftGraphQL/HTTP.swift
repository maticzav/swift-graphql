import Foundation
import GraphQL

extension URLRequest {
    
    /// Adds GraphQL query or mutation properties to an URLRequest.
    ///
    ///  - parameter selection: GraphQL Query or Mutation selection.
    ///  - parameter as: An operation name to use for the query.
    ///
    /// Here's a short example of how you can make a request and decode the result. In practice,
    /// we recomment using a client instead.
    ///
    ///
    /// ```
    /// let endpoint = URL(string: "https://mygraphql.com/graphql")!
    ///
    /// let query = Selection.Query<String> { try $0.helloworld() }
    /// let request = URLRequest(url: endpoint)
    /// request.query(query)
    ///
    /// URLSession.shared.dataTask { data, response, error in
    ///     guard let result = try? data?.decode(query) else {
    ///         return
    ///     }
    ///     print(result.data)
    /// }
    /// ```
    public mutating func query<T, TypeLock>(
        _ selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        extensions: [String: AnyCodable]? = nil,
        encoder: JSONEncoder = JSONEncoder()
    ) where TypeLock: GraphQLHttpOperation {
        self.httpMethod = "POST"
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = selection.encode(operationName: operationName, extensions: extensions)
        self.httpBody = try! encoder.encode(payload)
    }
    
    /// Adds GraphQL query and mutation properties to a new URLRequest
    /// and leaves the current one unchanges.
    ///
    /// - NOTE: For more information and example, check out `.query` function.
    public func querying<T, TypeLock>(
        _ selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        extensions: [String: AnyCodable]? = nil,
        encoder: JSONEncoder = JSONEncoder()
    ) -> URLRequest where TypeLock: GraphQLHttpOperation {
        var copy = self
        copy.query(selection, as: operationName, extensions: extensions, encoder: encoder)
        return copy
    }
}

extension Data {
    
    /// Decodes the response of a request made using SwiftGraphQL selection.
    public func decode<T, TypeLock>(
        _ selection: Selection<T, TypeLock>,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> (data: T, errors: [GraphQLError]?) where TypeLock: GraphQLHttpOperation {
        let result = try decoder.decode(ExecutionResult.self, from: self)
        let data = try selection.decode(raw: result.data)
        
        return (data, result.errors)
    }
}
