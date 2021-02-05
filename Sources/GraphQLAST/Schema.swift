import Foundation

// MARK: - Schema

public struct Schema: Decodable, Equatable {
    public let description: String?
    
    /// Collection of all types in the schema.
    public let types: [NamedType]

    /**
     Internal information about the types of root operations.
     */
    private let queryTypeName: String
    private let mutationTypeName: String?
    private let subscriptionTypeName: String?
}

// MARK: - Accessors

public extension Schema {
    
    /// Searches for a type with a given name.
    func type(name: String) -> NamedType? {
        types.first(where: { $0.name == name })
    }
    
    /// Searches for an object with a given name.
    func object(name: String) -> ObjectType? {
        objects.first(where: { $0.name == name })
    }
    
    // MARK: - Operations
    
    /// Query operation type in the schema.
    var query: Operation {
        .query(object(name: queryTypeName)!)
    }
    
    /// Mutation operation type in the schema.
    var mutation: Operation? {
        mutationTypeName
            .flatMap { object(name: $0) }
            .flatMap { .mutation($0) }
    }
    
    /// Subscription operation type in the schema.
    var subscription: Operation? {
        subscriptionTypeName
            .flatMap { object(name: $0) }
            .flatMap { .subscription($0) }
    }
    
    /// Returns operation types in the schema.
    var operations: [Operation] {
        [query, mutation, subscription].compactMap { $0 }
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
