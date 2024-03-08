import RxSwiftCombine
import Foundation
import GraphQL

#if canImport(GraphQLWebSocket)
import GraphQLWebSocket

extension GraphQLWebSocket {
    
    /// Subscribes to a subscription using SwiftGraphQL selection and returns a publisher
    /// emitting decoded received results.
    ///
    /// ```
    /// let endpoint = URL(string: "ws://mygraphql.com/graphql")!
    /// let client = GraphQLWebSocket(request: URLRequest(url: endpoint))
    ///
    /// let subscription = Selection.Subscription<String> { try $0.hello() }
    ///
    /// client.subscribe(subscription)
    ///     .sink { completion in
    ///         print(completion)
    ///     } receiveValue: { (result: String) in
    ///         print(result)
    ///     }
    /// ```
    public func subscribe<T, TypeLock>(
        _ selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        extensions: [String: AnyCodable]? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<DecodedExecutionResult<T>, Error> where TypeLock: GraphQLWebSocketOperation {
        let args = selection.encode(operationName: operationName, extensions: extensions)
        
        let publisher = self.subscribe(args)
            .map { result -> DecodedExecutionResult<T> in
                let data = try selection.decode(raw: result.data)
                let result = DecodedExecutionResult<T>(
                    data: data,
                    errors: result.errors,
                    hasNext: result.hasNext,
                    extensions: result.extensions
                )
                
                return result
            }
            .eraseToAnyPublisher()
        
        return publisher
    }
}
#endif
