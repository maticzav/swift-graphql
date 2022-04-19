//import Combine
import Foundation

/*
 SwiftGraphQL has no client as it needs no state. Developers
 should take care of caching and other implementation themselves.
 */

// MARK: - Send

/// Sends a query request to the server.
///
/// - parameter endpoint: Server endpoint URL.
/// - parameter operationName: The name of the GraphQL query.
/// - parameter headers: A dictionary of key-value header pairs.
/// - parameter onEvent: Closure that is called each subscription event.
/// - parameter method: Method to use. (Default to POST).
/// - parameter session: URLSession to use. (Default to .shared).
///
@discardableResult
public func send<Type, TypeLock>(
    _ selection: Selection<Type, TypeLock?>,
    to endpoint: String,
    operationName: String? = nil,
    headers: HttpHeaders = [:],
    method: HttpMethod = .post,
    session: URLSession = .shared,
    onComplete completionHandler: @escaping (Response<Type, TypeLock>) -> Void
) -> URLSessionDataTask? where TypeLock: GraphQLHttpOperation & Decodable {
    send(
        selection: selection,
        operationName: operationName,
        endpoint: endpoint,
        headers: headers,
        method: method,
        session: session,
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
/// - parameter session: URLSession to use. (Default to .shared).
///
@discardableResult
public func send<Type, TypeLock>(
    _ selection: Selection<Type, TypeLock>,
    to endpoint: String,
    operationName: String? = nil,
    headers: HttpHeaders = [:],
    method: HttpMethod = .post,
    session: URLSession = .shared,
    onComplete completionHandler: @escaping (Response<Type, TypeLock>) -> Void
) -> URLSessionDataTask? where TypeLock: GraphQLHttpOperation & Decodable {
    send(
        selection: selection.nonNullOrFail,
        operationName: operationName,
        endpoint: endpoint,
        headers: headers,
        method: method,
        session: session,
        completionHandler: completionHandler
    )
}


/// Sends a query to the server using given parameters.
private func send<Type, TypeLock>(
    selection: Selection<Type, TypeLock?>,
    operationName: String?,
    endpoint: String,
    headers: HttpHeaders,
    method: HttpMethod,
    session: URLSession,
    completionHandler: @escaping (Response<Type, TypeLock>) -> Void
) -> URLSessionDataTask? where TypeLock: GraphQLOperation & Decodable {
    // Validate that we got a valid url.
    guard let url = URL(string: endpoint) else {
        completionHandler(.failure(.badURL))
        return nil
    }
    
    // Construct a GraphQL request.
    let request = createGraphQLRequest(
        selection: selection,
        operationName: operationName,
        url: url,
        headers: headers,
        method: method
    )
    
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
        if let data = data {
            do {
                let result = try GraphQLResult(data, with: selection)
                return completionHandler(.success(result))
            } catch let error as HttpError {
                return completionHandler(.failure(error))
            } catch let error {
                return completionHandler(.failure(.decodingError(error)))
            }
        }

        return completionHandler(.failure(.badpayload))
    }

    // Construct a session data task.
    let dataTask = session.dataTask(with: request, completionHandler: onComplete)
    
    dataTask.resume()
    return dataTask
    
}


// MARK: - Request type aliaii

/// Represents an error of the actual request.
public enum HttpError: Error {
    case badURL
    case timeout
    case network(Error)
    case badpayload
    case badstatus
    case cancelled
    case decodingError(Error)
}

extension HttpError: Equatable {
    public static func == (lhs: SwiftGraphQL.HttpError, rhs: SwiftGraphQL.HttpError) -> Bool {
        // Equals if they are of the same type, different otherwise.
        switch (lhs, rhs) {
        case (.badURL, badURL),
            (.timeout, .timeout),
            (.badpayload, .badpayload),
            (.badstatus, .badstatus),
            (.cancelled, .cancelled),
            (.network, network),
            (.decodingError, decodingError):
            return true
        default:
            return false
        }
    }
}


public enum HttpMethod: String, Equatable {
    case get = "GET"
    case post = "POST"
}

/// A return value that might contain a return value as described in GraphQL spec.
public typealias Response<Type, TypeLock> = Result<GraphQLResult<Type, TypeLock>, HttpError>

/// A dictionary of key-value pairs that represent headers and their values.
public typealias HttpHeaders = [String: String]

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

    // Construct HTTP body.
    let encoder = JSONEncoder()
    let payload = selection.buildPayload(operationName: operationName)
    request.httpBody = try! encoder.encode(payload)

    return request
}

