import Foundation
import GraphQLWebSocket
import SwiftGraphQLClient


enum NetworkClient {
    // Local Instance
    // static private var http = URL(string: "http://127.0.0.1:4000/graphql")!
    // static private var ws = URL(string: "ws://127.0.0.1:4000/graphql")!

    // With Hosted Server
    static private var http = URL(string: "https://thesocialnetwork.swift-graphql.com/graphql")!
    static private var ws = URL(string: "wss://thesocialnetwork.swift-graphql.com/graphql")!
    
    static private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    static private var wsconfig: GraphQLWebSocketConfiguration {
        let config = GraphQLWebSocketConfiguration()
        config.encoder = encoder
        return config
    }
    
    static private var socket: GraphQLWebSocket = GraphQLWebSocket(
        request: URLRequest(url: ws), 
        config: wsconfig
    )
    
    /// Exchange that takes care of the caching of results.
    static let cache = CacheExchange()
    
    /// Instance of the GraphQL client that may be used by all services.
    static let shared: GraphQLClient = SwiftGraphQLClient.Client(
        request: URLRequest(url: http),
        exchanges: [
            DedupExchange(),
            AuthExchange(header: "Authentication", getToken: {
                if let token = AuthClient.getToken() {
                    return "Bearer \(token)"
                }
                
                return nil
            }),
            ExtensionsExchange({ op in
                guard let token = AuthClient.getToken() else {
                    return nil
                }
                return ["headers": ["Authentication": "Bearer \(token)"]]
            }),
            cache,
            FetchExchange(encoder: encoder),
            WebSocketExchange(client: socket)
        ]
    )
}
