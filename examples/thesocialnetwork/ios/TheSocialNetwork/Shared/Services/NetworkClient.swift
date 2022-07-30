import Foundation
import GraphQLWebSocket
import SwiftGraphQLClient


enum NetworkClient {
    static private var http: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:4000/graphql")!)
    static private var ws: URLRequest = URLRequest(url: URL(string: "ws://127.0.0.1:4000/graphql")!)
    
    static private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    static private var wsconfig: GraphQLWebSocketConfiguration {
        let config = GraphQLWebSocketConfiguration()
        config.behaviour = .lazy(closeTimeout: 60)
        config.connectionParams = {
            guard let token = AuthClient.getToken() else {
                return nil
            }
            return ["headers": ["Authentication": "Bearer \(token)"]]
        }
        config.encoder = encoder
        return config
    }
    
    static private var socket: GraphQLWebSocket = GraphQLWebSocket(request: ws, config: wsconfig)
    
    /// Exchange that takes care of the caching of results.
    static let cache = CacheExchange()
    
    /// Instance of the GraphQL client that may be used by all services.
    static let shared: GraphQLClient = SwiftGraphQLClient.Client(
        request: http,
        exchanges: [
            DedupExchange(),
            AuthExchange(header: "Authentication", getToken: {
                if let token = AuthClient.getToken() {
                    return "Bearer \(token)"
                }
                
                return nil
            }),
            cache,
            FetchExchange(encoder: encoder),
            WebSocketExchange(client: socket)
        ]
    )
}
