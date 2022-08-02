import Foundation
import GraphQLWebSocket
import SwiftGraphQLClient


enum NetworkClient {
    static private var url: URL = URL(string: "https://api.github.com/graphql")!
    static private var http: URLRequest = URLRequest(url: url)
    
    static private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    
    /// Exchange that takes care of the caching of results.
    static let cache = CacheExchange()
    
    /// Instance of the GraphQL client that may be used by all services.
    static let shared: GraphQLClient = SwiftGraphQLClient.Client(
        request: http,
        exchanges: [
            DedupExchange(),
            AuthExchange(header: "Authorization", getToken: {
                if let token = AuthClient.getToken() {
                    return "bearer \(token)"
                }
                return nil
            }),
            cache,
            FetchExchange(encoder: encoder)
        ]
    )
}
