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
        as operationName: String? = nil
    ) where TypeLock: GraphQLOperation & Decodable {
        self.httpMethod = "POST"
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let payload = selection.encode(operationName: operationName)
        self.httpBody = try! encoder.encode(payload)
    }
    
    /// Adds GraphQL query and mutation properties to a new URLRequest
    /// and leaves the current one unchanges.
    ///
    /// - NOTE: For more information and example, check out `.query` function.
    public func querying<T, TypeLock>(
        _ selection: Selection<T, TypeLock>,
        as operationName: String? = nil
    ) -> URLRequest where TypeLock: GraphQLOperation & Decodable {
        var copy = self
        copy.query(selection, as: operationName)
        return copy
    }
}

extension Data {
    
    /// Decodes the response of a request made using SwiftGraphQL selection.
    func decode<T, TypeLock>(
        _ selection: Selection<T, TypeLock>
    ) throws -> ExecutionResult<T> where TypeLock: GraphQLOperation & Decodable {
        let (data, errors) = try selection.decode(raw: self)
        return ExecutionResult(data: data, errors: errors)
    }
}
