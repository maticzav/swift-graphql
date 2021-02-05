import Foundation

// MARK: - Schema

public struct Schema: Decodable, Equatable {
    public let description: String?
    public let types: [NamedType]
    /* Root Types */
    public let queryType: Operation
    public let mutationType: Operation?
    public let subscriptionType: Operation?
}

// MARK: - Operations

public struct Operation: Codable, Equatable {
    public let name: String
}

// MARK: - Methods

public extension Schema {
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
    var objects: [ObjectType] {
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
    var interfaces: [InterfaceType] {
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
    var unions: [UnionType] {
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
    var enums: [EnumType] {
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
    var inputObjects: [InputObjectType] {
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
