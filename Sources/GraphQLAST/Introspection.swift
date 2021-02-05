import Foundation

/*
 We use the common introspection Query to construct the library.
 You can find remaining utility types that represent the result
 of the schema introspection inside AST folder.

 I've namespaced every GraphQL and GraphQL schema related values
 and functions to GraphQL enum.
 */

// MARK: - Introspection Query

/// IntrospectionQuery that you should use to fetch data.
///
/// - Note: If you use a different introspection query, GraphQLAST might not be able to
///         correctly parse it.
public let introspectionQuery: String = """
query IntrospectionQuery($includeDeprecated: Boolean = true) {
    __schema {
        queryType { name }
        mutationType { name }
        subscriptionType { name }
        types {
        ...FullType
        }
    }
}

fragment FullType on __Type {
    kind
    name
    description
    fields(includeDeprecated: $includeDeprecated) {
        ...Field
    }
    inputFields {
        ...InputValue
    }
    interfaces {
        ...TypeRef
    }
    enumValues(includeDeprecated: $includeDeprecated) {
        ...EnumValue
    }
    possibleTypes {
        ...TypeRef
    }
}

fragment Field on __Field {
    name
    description
    args {
        ...InputValue
    }
    type {
        ...TypeRef
    }
    isDeprecated
    deprecationReason
}

fragment InputValue on __InputValue {
    name
    description
    type {
        ...TypeRef
    }
    defaultValue
}

fragment EnumValue on __EnumValue {
    name
    description
    isDeprecated
    deprecationReason
}



fragment TypeRef on __Type {
    kind
    name
    ofType {
        kind
        name
        ofType {
            kind
            name
            ofType {
                kind
                name
                ofType {
                    kind
                    name
                    ofType {
                        kind
                        name
                        ofType {
                            kind
                            name
                            ofType {
                                kind
                                name
                            }
                        }
                    }
                }
            }
        }
    }
}
"""

// MARK: - Parser

/// Decodes the received schema representation into Swift abstract type.
public func parse(_ data: Data) throws -> Schema {
    let decoder = JSONDecoder()
    let result = try decoder.decode(Reponse<IntrospectionQuery>.self, from: data)

    return result.data.schema
}

// MARK: - Internals

/// Represents a GraphQL response.
private struct Reponse<T: Decodable>: Decodable {
    public let data: T
}

extension Reponse: Equatable where T: Equatable {}

/// Represents introspection query return type in GraphQL response.
private struct IntrospectionQuery: Decodable, Equatable {
    public let schema: Schema

    enum CodingKeys: String, CodingKey {
        case schema = "__schema"
    }
}

// MARK: - Loader

/// Fetches a schema from the provided endpoint using introspection query.
func fetch(from endpoint: URL) throws -> Data {
    /* Compose a request. */
    var request = URLRequest(url: endpoint)

    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpMethod = "POST"

    let query: [String: Any] = ["query": introspectionQuery]

    request.httpBody = try! JSONSerialization.data(
        withJSONObject: query,
        options: JSONSerialization.WritingOptions()
    )

    /* Semaphore */
    let semaphore = DispatchSemaphore(value: 0)
    var result: Result<Data, IntrospectionError>?

    /* Load the schema. */
    URLSession.shared.dataTask(with: request) { data, response, error in
        /* Check for errors. */
        if let error = error {
            result = .failure(.error(error))
            semaphore.signal()
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
            result = .failure(.statusCode)
            semaphore.signal()
            return
        }

        /* Save JSON to file. */
        if let data = data {
            result = .success(data)
            semaphore.signal()
            return
        }
    }.resume()

    /* Result */
    _ = semaphore.wait(wallTimeout: .distantFuture)

    switch result {
    case let .success(data):
        return data
    case let .failure(error):
        throw error
    default:
        throw IntrospectionError.unknown
    }
}

enum IntrospectionError: Error {
    case error(Error)
    case statusCode
    case unknown
}

// MARK: - Extension

public extension Schema {
    /// Downloads a schema from the provided endpoint.
    init(from endpoint: URL) throws {
        let introspection: Data = try fetch(from: endpoint)
        self = try parse(introspection)
    }
}
