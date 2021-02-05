import Foundation

/*
 We use the common introspection Query to construct the library.
 You can find remaining utility types that represent the result
 of the schema introspection inside AST folder.

 I've namespaced every GraphQL and GraphQL schema related values
 and functions to GraphQL enum.
 */

// MARK: - Methods

/// Decodes the received schema representation into Swift abstract type.
public func parse(_ data: Data) throws -> Schema {
    let decoder = JSONDecoder()
    let result = try decoder.decode(Reponse<IntrospectionQuery>.self, from: data)

    return result.data.schema
}

// MARK: - Intermediate decodables

struct Reponse<T: Decodable>: Decodable {
    public let data: T
}

struct IntrospectionQuery: Decodable, Equatable {
    public let schema: Schema

    enum CodingKeys: String, CodingKey {
        case schema = "__schema"
    }
}

// MARK: - Introspection Query

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

// MARK: - Extensions

extension Reponse: Equatable where T: Equatable {}
