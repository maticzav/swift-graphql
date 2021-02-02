import Foundation

extension GraphQL {
    // MARK: - Schema

    struct Schema: Decodable, Equatable {
        let description: String?
        let types: [NamedType]
        /* Root Types */
        let queryType: Operation
        let mutationType: Operation?
        let subscriptionType: Operation?
    }

    // MARK: - Operations

    struct Operation: Codable, Equatable {
        let name: String
    }
}

// MARK: - Methods

extension GraphQL.Schema {
    /// Returns names of the operations in schema.
    var operations: [String] {
        [
            queryType.name,
            mutationType?.name,
            subscriptionType?.name,
        ].compactMap { $0 }
    }

    // MARK: - Named types

    /// Returns object definitions from schema.
    var objects: [GraphQL.ObjectType] {
        types.compactMap {
            switch $0 {
            case let .object(type) where !type.isInternal:
                return type
            default:
                return nil
            }
        }
    }

    /// Returns object definitions from schema.
    var interfaces: [GraphQL.InterfaceType] {
        types.compactMap {
            switch $0 {
            case let .interface(type) where !type.isInternal:
                return type
            default:
                return nil
            }
        }
    }

    /// Returns object definitions from schema.
    var unions: [GraphQL.UnionType] {
        types.compactMap {
            switch $0 {
            case let .union(type) where !type.isInternal:
                return type
            default:
                return nil
            }
        }
    }

    /// Returns enumerator definitions in schema.
    var enums: [GraphQL.EnumType] {
        types.compactMap {
            switch $0 {
            case let .enum(type) where !type.isInternal:
                return type
            default:
                return nil
            }
        }
    }

    /// Returns input object definitions from schema.
    var inputObjects: [GraphQL.InputObjectType] {
        types.compactMap {
            switch $0 {
            case let .inputObject(type) where !type.isInternal:
                return type
            default:
                return nil
            }
        }
    }
}
