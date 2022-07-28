import Foundation
import GraphQLWebSocket
import SwiftGraphQLClient


enum NetworkClient {
    static var http: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:4000/graphql")!)
    static var ws: URLRequest = URLRequest(url: URL(string: "ws://127.0.0.1:4000/graphql")!)
    
    static var config = ClientConfiguration()
    
    static var socket: GraphQLWebSocket = GraphQLWebSocket(request: ws)
    
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
            CacheExchange(),
            FetchExchange(),
            WebSocketExchange(client: socket)
        ],
        config: config
    )
}
