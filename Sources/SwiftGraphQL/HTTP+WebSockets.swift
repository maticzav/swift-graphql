//import Combine
import Foundation

/*
 SwiftGraphQL has no client as it needs no state. Developers
 should take care of caching and other implementation themselves.
 */

public enum WebSocketProtocol: String {
    /// This is the recommended protocol
    ///
    /// https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md
    case graphqlTransportWs = "graphql-transport-ws"
    
    /// This protocol is deprecated, explanation: https://the-guild.dev/blog/graphql-over-websockets
    ///
    /// https://github.com/apollographql/subscriptions-transport-ws/blob/master/PROTOCOL.md
    @available(*, deprecated, message: "Use only if your server does not support graphql-transport-ws")
    case graphqlWs = "graphql-ws"
    
    func connectionInit(connectionParams: [String: Any]?) -> Data {
        var message: [String: Any] = [
            "type": "connection_init"
        ]
        
        if let connectionParams = connectionParams {
            message["payload"] = connectionParams
        }
        
        return try! JSONSerialization.data(withJSONObject: message)
    }
    
    func subscribe(id: String, payload: [String: Any]) -> Data {
        let message: [String: Any] = [
            "payload": payload,
            "id": id,
            "type": self == .graphqlTransportWs ? "subscribe" : "start"
        ]
        
        return try! JSONSerialization.data(withJSONObject: message)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func startWebSocket(
    on endpoint: String,
    headers: HttpHeaders = [:],
    connectionParams: [String: Any]? = nil,
    protocol webSocketProtocol: WebSocketProtocol = .graphqlTransportWs,
    completion: @escaping (Result<URLSessionWebSocketTask, HttpError>) -> Void
) {
    guard let url = URL(string: endpoint) else {
        return completion(.failure(HttpError.badURL))
    }
    
    // Construct a request.
    var request = URLRequest(url: url)

    for header in headers {
        request.setValue(header.value, forHTTPHeaderField: header.key)
    }

    request.setValue(webSocketProtocol.rawValue, forHTTPHeaderField: "Sec-WebSocket-Protocol")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "GET"
    
    let socket: URLSessionWebSocketTask = URLSession.shared.webSocketTask(with: request)
    
    // GQL_CONNECTION_INIT
    // Client sends this message after plain websocket connection to start the communication with the server
    socket.send(.data(webSocketProtocol.connectionInit(connectionParams: connectionParams))) { error in
        if let error = error {
            return completion(.failure(HttpError.network(error)))
        }
    }
    
    socket.receive { result in
        switch result {
        case let .failure(error):
            completion(.failure(.network(error)))
        case let .success(message):
            if let data = message.data {
                let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                if jsonObject?["type"] as? String == "connection_ack" {
                    completion(.success(socket))
                } else {
                    completion(.failure(.badpayload))
                }
            }
        }
    }
    
    socket.resume()
}

// MARK: - Listen

/// Starts a webhook listener and returns a URLSessionWebSocket that you may use to manipulate session.
///
/// - parameter endpoint: Server endpoint URL.
/// - parameter operationName: The name of the GraphQL query.
/// - parameter headers: A dictionary of key-value header pairs.
/// - parameter onEvent: Closure that is called each subscription event.
///
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func listen<Type, TypeLock>(
    for selection: Selection<Type, TypeLock?>,
    on webSocket: URLSessionWebSocketTask,
    operationName: String? = nil,
    onEvent eventHandler: @escaping (Response<Type, TypeLock>) -> Void
) -> Void where TypeLock: GraphQLWebSocketOperation & Decodable {
    listen(
        selection: selection,
        operationName: operationName,
        webSocket: webSocket,
        eventHandler: eventHandler
    )
}

/// Starts a webhook listener and returns a URLSessionWebSocket that you may use to manipulate session.
///
/// - Note: This is a shortcut function for when you are expecting the result.
///         The only difference between this one and the other one is that you may select
///         on non-nullable TypeLock instead of a nullable one.
///
/// - parameter endpoint: Server endpoint URL.
/// - parameter operationName: The name of the GraphQL query.
/// - parameter headers: A dictionary of key-value header pairs.
/// - parameter onEvent: Closure that is called each subscription event.
///
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func listen<Type, TypeLock>(
    for selection: Selection<Type, TypeLock>,
    on webSocket: URLSessionWebSocketTask,
    operationName: String? = nil,
    onEvent eventHandler: @escaping (Response<Type, TypeLock>) -> Void
) -> Void where TypeLock: GraphQLWebSocketOperation & Decodable {
    listen(
        selection: selection.nonNullOrFail,
        operationName: operationName,
        webSocket: webSocket,
        eventHandler: eventHandler
    )
}

/// Starts a webhook listener and returns a URLSessionWebSocket that you may use to close session.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private func listen<Type, TypeLock>(
    selection: Selection<Type, TypeLock?>,
    operationName: String?,
    webSocket: URLSessionWebSocketTask,
    eventHandler: @escaping (Response<Type, TypeLock>) -> Void
) -> Void where TypeLock: GraphQLWebSocketOperation & Decodable {
    // Get the protocol
    guard
        let wsProtocolStr = webSocket.originalRequest?.value(forHTTPHeaderField: "Sec-WebSocket-Protocol"),
        let wsProtocol = WebSocketProtocol(rawValue: wsProtocolStr)
    else {
        // TODO: error badprotocol
        return eventHandler(.failure(.badURL))
    }

    // Compose a query.
    let query = selection.selection.serialize(for: TypeLock.operation, operationName: operationName)
    var variables = [String: NSObject]()

    for argument in selection.selection.arguments {
        variables[argument.hash] = argument.value
    }

    // Construct the payload.
    var payload: [String: Any] = [
        "query": query,
        "variables": variables,
    ]

    if let operationName = operationName {
        // Add the operation name to the request body if needed.
        payload["operationName"] = operationName
    }
    
    let id = UUID().uuidString

    // Create an event handler.
    func receiveNext(on socket: URLSessionWebSocketTask?) {
        socket?.receive { [weak socket] result in
            /* Process the response. */
            switch result {
            case let .failure(error):
                eventHandler(.failure(.network(error)))
            case let .success(message):
                // Try to serialize the response.
                if let data = message.data {
                    let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if jsonObject?["type"] as? String == "data" {
                        if let result = try? GraphQLResult(webSocketResponse: data, with: selection) {
                            eventHandler(.success(result))
                        } else {
                            eventHandler(.failure(.badpayload))
                        }
                    }
                }   
            }

            // Receive next message
            receiveNext(on: socket)
        }
    }
    
    // Attach receiver
    receiveNext(on: webSocket)

    // Send message
    webSocket.send(.data(wsProtocol.subscribe(id: id, payload: payload))) { error in
        if error != nil {
            eventHandler(.failure(.badpayload))
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension URLSessionWebSocketTask.Message {
    var data: Data? {
        switch self {
        case let .data(data):
            return data
        case let .string(string):
            return string.data(using: .utf8)
        @unknown default:
            return nil
        }
    }
}





// MARK: - Utility functions

/*
 Each of the exposed functions has a backing private helper.
 We use `perform` method to send queries and mutations,
 `listen` to listen for subscriptions, and there's an overarching utility
 `request` method that composes a request and send it.
 */

/// Creates a valid URLRequest using given selection.
private func createGraphQLRequest<Type, TypeLock>(
    selection: Selection<Type, TypeLock?>,
    operationName: String?,
    url: URL,
    headers: HttpHeaders,
    method: HttpMethod
) -> URLRequest where TypeLock: GraphQLOperation & Decodable {
    // Construct a request.
    var request = URLRequest(url: url)

    for header in headers {
        request.setValue(header.value, forHTTPHeaderField: header.key)
    }

    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = method.rawValue

    // Compose a query.
    let query = selection.selection.serialize(for: TypeLock.operation, operationName: operationName)
    var variables = [String: NSObject]()

    for argument in selection.selection.arguments {
        variables[argument.hash] = argument.value
    }

    // Construct a request body.
    var body: [String: Any] = [
        "query": query,
        "variables": variables,
    ]

    if let operationName = operationName {
        // Add the operation name to the request body if needed.
        body["operationName"] = operationName
    }

    // Construct a HTTP request.
    request.httpBody = try! JSONSerialization.data(withJSONObject: body)

    return request
}

