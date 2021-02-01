import Foundation

/*
 SwiftGraphQL has no client as it needs no state. Developers
 should take care of caching and other implementation themselves.

 The following code defines a SwiftGraphQL namespace and exposes functions
 that developers can use to execute queries against their server.
 */

public enum SwiftGraphQL {
    // MARK: - Public Methods

    /// Sends a query request to the server.
    ///
    /// - parameter endpoint: Server endpoint URL.
    /// - parameter operationName: The name of the GraphQL query.
    /// - parameter headers: A dictionary of key-value header pairs.
    /// - parameter onEvent: Closure that is called each subscription event.
    /// - parameter method: Method to use. (Default to POST).
    ///
    public static func send<Type, TypeLock>(
        _ selection: Selection<Type, TypeLock?>,
        to endpoint: String,
        operationName: String? = nil,
        headers: HttpHeaders = [:],
        method: HttpMethod = .post,
        onComplete completionHandler: @escaping (Response<Type, TypeLock>) -> Void
    ) -> Void where TypeLock: GraphQLHttpOperation & Decodable {
        perform(
            selection: selection,
            operationName: operationName,
            endpoint: endpoint,
            headers: headers,
            method: method,
            completionHandler: completionHandler
        )
    }

    /// Sends a query request to the server.
    ///
    /// - Note: This is a shortcut function for when you are expecting the result.
    ///         The only difference between this one and the other one is that you may select
    ///         on non-nullable TypeLock instead of a nullable one.
    ///
    /// - parameter endpoint: Server endpoint URL.
    /// - parameter operationName: The name of the GraphQL query.
    /// - parameter headers: A dictionary of key-value header pairs.
    /// - parameter onEvent: Closure that is called each subscription event.
    /// - parameter method: Method to use. (Default to POST).
    ///
    public static func send<Type, TypeLock>(
        _ selection: Selection<Type, TypeLock>,
        to endpoint: String,
        operationName: String? = nil,
        headers: HttpHeaders = [:],
        method: HttpMethod = .post,
        onComplete completionHandler: @escaping (Response<Type, TypeLock>) -> Void
    ) -> Void where TypeLock: GraphQLHttpOperation & Decodable {
        perform(
            selection: selection.nonNullOrFail,
            operationName: operationName,
            endpoint: endpoint,
            headers: headers,
            method: method,
            completionHandler: completionHandler
        )
    }

    /// Observe a subscription for as long as you keep Token in memory
    ///
    /// - parameter endpoint: Server endpoint URL.
    /// - parameter operationName: The name of the GraphQL query.
    /// - parameter headers: A dictionary of key-value header pairs.
    /// - parameter onEvent: Closure that is called each subscription event.
    ///
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public static func listen<Type, TypeLock>(
        for selection: Selection<Type, TypeLock?>,
        on endpoint: String,
        operationName: String? = nil,
        headers: HttpHeaders = [:],
        protocol webSocketProtocol: String = "graphql-subscriptions",
        onEvent eventHandler: @escaping (Response<Type, TypeLock>) -> Void
    ) -> Token where TypeLock: GraphQLWebSocketOperation & Decodable {
        listen(
            selection: selection,
            operationName: operationName,
            endpoint: endpoint,
            headers: headers,
            webSocketProtocol: webSocketProtocol,
            eventHandler: eventHandler
        )
    }

    /// Observe a subscription for as long as you keep Token in memory
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
    public static func listen<Type, TypeLock>(
        _ selection: Selection<Type, TypeLock>,
        to endpoint: String,
        operationName: String? = nil,
        headers: HttpHeaders = [:],
        protocol webSocketProtocol: String = "graphql-subscriptions",
        onEvent eventHandler: @escaping (Response<Type, TypeLock>) -> Void
    ) -> Token where TypeLock: GraphQLWebSocketOperation & Decodable {
        listen(
            selection: selection.nonNullOrFail,
            operationName: operationName,
            endpoint: endpoint,
            headers: headers,
            webSocketProtocol: webSocketProtocol,
            eventHandler: eventHandler
        )
    }

    /// Represents an error of the actual request.
    public enum HttpError: Error {
        case badURL
        case timeout
        case network(Error)
        case badpayload
        case badstatus
        case cancelled
    }

    public enum HttpMethod: String, Equatable {
        case get = "GET"
        case post = "POST"
    }

    public typealias Response<Type, TypeLock> = Result<GraphQLResult<Type, TypeLock>, HttpError>

    public typealias HttpHeaders = [String: String]

    // MARK: - Private Helpers

    /*
     Each of the exposed functions has a backing private helper.
     We use `perform` method to send queries and mutations,
     `listen` to listen for subscriptions, and there's an overarching utility
     `request` method that composes a request and send it.

     We use `request` in both `perform` and `listen` methods.
     */

    private static func request<Type, TypeLock>(
        selection: Selection<Type, TypeLock?>,
        operationName: String?,
        endpoint: String,
        headers: HttpHeaders,
        method: HttpMethod
    ) -> Result<URLRequest, HttpError> where TypeLock: GraphQLOperation & Decodable {
        guard let url = URL(string: endpoint) else {
            return .failure(.badURL)
        }

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
        request.httpBody = try! JSONSerialization.data(
            withJSONObject: body,
            options: []
        )

        return .success(request)
    }

    /// Sends a query to the server using given parameters.
    private static func perform<Type, TypeLock>(
        selection: Selection<Type, TypeLock?>,
        operationName: String?,
        endpoint: String,
        headers: HttpHeaders,
        method: HttpMethod,
        completionHandler: @escaping (Response<Type, TypeLock>) -> Void
    ) -> Void where TypeLock: GraphQLOperation & Decodable {
        switch request(selection: selection, operationName: operationName, endpoint: endpoint, headers: headers, method: method) {
        case let .failure(error):
            return completionHandler(.failure(error))
        case let .success(request):
            // Create a completion handler.
            func onComplete(data: Data?, response: URLResponse?, error: Error?) {
                /* Process the response. */
                // Check for HTTP errors.
                if let error = error {
                    return completionHandler(.failure(.network(error)))
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200 ... 299).contains(httpResponse.statusCode)
                else {
                    return completionHandler(.failure(.badstatus))
                }

                // Try to serialize the response.
                if let data = data, let result = try? GraphQLResult(data, with: selection) {
                    return completionHandler(.success(result))
                }

                return completionHandler(.failure(.badpayload))
            }

            // Construct a session.
            URLSession.shared.dataTask(with: request, completionHandler: onComplete).resume()
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    /// Starts a webhook listener.
    private static func listen<Type, TypeLock>(
        selection: Selection<Type, TypeLock?>,
        operationName: String?,
        endpoint: String,
        headers: HttpHeaders,
        webSocketProtocol: String,
        eventHandler: @escaping (Response<Type, TypeLock>) -> Void
    ) -> Token where TypeLock: GraphQLWebSocketOperation & Decodable {
        switch request(selection: selection, operationName: operationName, endpoint: endpoint, headers: headers, method: .get) {
        case let .failure(error):
            eventHandler(.failure(error))
            return Token.empty
        case var .success(request):
            if request.value(forHTTPHeaderField: "Sec-WebSocket-Protocol") == nil {
                request.setValue(webSocketProtocol, forHTTPHeaderField: "Sec-WebSocket-Protocol")
            }

            // Construct a message.
            let message: [String: Any] = [
                "payload": try! JSONSerialization.jsonObject(with: request.httpBody!, options: []),
                "type": "start",
                // "id": UUID().uuidString
            ]
            request.httpBody = nil

            let messageData = try! JSONSerialization.data(
                withJSONObject: message,
                options: []
            )

            // Create an event handler.
            func receiveNext(on socket: URLSessionWebSocketTask?) {
                socket?.receive { [weak socket] result in
                    /* Process the response. */
                    switch result {
                    case let .failure(error):
                        if socket?.closeReason == WebSocketCloseReason.tokenDeinit {
                            return eventHandler(.failure(.cancelled))
                        } else {
                            return eventHandler(.failure(.network(error)))
                        }
                    case let .success(message):
                        print("MSG", message)
                        // Try to serialize the response.
                        if let data = message.data {
                            print("DATA", data)
                            if let result = try? GraphQLResult(webSocketResponse: data, with: selection) {
                                eventHandler(.success(result))
                            }
                        } else {
                            eventHandler(.failure(.badpayload))
                        }
                    }

                    // Receive next message
                    receiveNext(on: socket)
                }
            }

            // Construct a session.
            let socket: URLSessionWebSocketTask = URLSession.shared.webSocketTask(with: request)

            // Attach receiver
            receiveNext(on: socket)

            // Send message
            socket.send(.data(messageData)) { error in
                if let error = error {
                    print(error)
                    eventHandler(.failure(.badpayload))
                }
            }
            socket.resume()

            return Token {
                socket.cancel(with: .goingAway, reason: WebSocketCloseReason.tokenDeinit)
            }
        }
    }
}

extension SwiftGraphQL.HttpError: Equatable {
    public static func == (lhs: SwiftGraphQL.HttpError, rhs: SwiftGraphQL.HttpError) -> Bool {
        // Equals if they are of the same type, different otherwise.
        switch (lhs, rhs) {
        case (.badURL, badURL),
             (.timeout, .timeout),
             (.badpayload, .badpayload),
             (.badstatus, .badstatus):
            return true
        default:
            return false
        }
    }
}

public class Token {
    private var onDeinit: () -> Void
    internal init(onDeinit: @escaping () -> Void) {
        self.onDeinit = onDeinit
    }

    deinit {
        onDeinit()
    }

    static var empty = Token(onDeinit: {})
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

internal enum WebSocketCloseReason {
    static var tokenDeinit = "Token deinit".data(using: .utf8)
}
