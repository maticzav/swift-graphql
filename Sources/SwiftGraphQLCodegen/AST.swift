import Foundation

public enum GraphQL {
    public static let introspectionQuery: String = """
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
    
    // MARK: - Methods
     
     /// Decodes the received schema representation into Swift abstract type.
     static func parse(_ data: Data) -> Schema {
         let decoder = JSONDecoder()
         let result = try! decoder.decode(Reponse<IntrospectionQuery>.self, from: data)
         
         return result.data.schema
     }
    
    // MARK: - Intermediate decodables
    
    /* General response format. */
    struct Reponse<T: Decodable>: Decodable {
        public let data: T
    }
    
    /* Introspection query decoders. */
    
    struct IntrospectionQuery: Decodable, Equatable {
        public let schema: Schema
        
        enum CodingKeys: String, CodingKey {
            case schema = "__schema"
        }
    }
}

// MARK: - Extensions

extension GraphQL.Reponse: Equatable where T: Equatable {}
