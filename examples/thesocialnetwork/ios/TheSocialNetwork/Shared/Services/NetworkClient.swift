import Foundation
import GraphQLWebSocket
import SwiftGraphQLClient


enum NetworkClient {
    static private var http: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:4000/graphql")!)
    static private var ws: URLRequest = URLRequest(url: URL(string: "ws://127.0.0.1:4000/graphql")!)
    
    static private var wsconfig: GraphQLWebSocketConfiguration {
        var config = GraphQLWebSocketConfiguration()
        config.behaviour = .lazy(closeTimeout: 60)
        config.connectionParams = {
            guard let token = AuthClient.getToken() else {
                return nil
            }
            return ["headers": ["Authentication": "Bearer \(token)"]]
        }
        
        return config
    }
    
    static private var socket: GraphQLWebSocket = GraphQLWebSocket(request: ws, config: wsconfig)
    
    /// Exchange that takes care of the caching of results.
    static private(set) var cache = CacheExchange()
    
    /// Instance of the GraphQL client that may be used by all services.
    static var shared: GraphQLClient = SwiftGraphQLClient.Client(
        url: http,
        exchanges: [
            DedupExchange(),
            AuthExchange(header: "Authentication", getToken: {
                if let token = AuthClient.getToken() {
                    return "Bearer \(token)"
                }
                
                return nil
            }),
            cache,
            FetchExchange(),
            WebSocketExchange(client: socket)
        ]
    )
}
