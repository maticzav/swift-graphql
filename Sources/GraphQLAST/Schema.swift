import Foundation

// MARK: - Schema

public struct Schema: Decodable, Equatable {
    /// Collection of all types in the schema.
    public let types: [NamedType]

    private let _query: String
    private let _mutation: String?
    private let _subscription: String?

    // MARK: - Initializer

    public init(types: [NamedType], query: String, mutation: String? = nil, subscription: String? = nil) {
        self.types = types

        _query = query
        _mutation = mutation
        _subscription = subscription
    }

    // MARK: - Decoder

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        types = try container.decode([NamedType].self, forKey: .types)
        _query = try container.decode(_Operation.self, forKey: .query).name
        _mutation = try container.decode(_Operation?.self, forKey: .mutation)?.name
        _subscription = try container.decode(_Operation?.self, forKey: .subscription)?.name
    }

    private enum CodingKeys: String, CodingKey {
        case types
        case query = "queryType"
        case mutation = "mutationType"
        case subscription = "subscriptionType"
    }

    private struct _Operation: Codable {
        var name: String
    }
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
    
    /// Searches for an input object with a given name.
    func inputObject(name: String) -> InputObjectType? {
        inputObjects.first(where: { $0.name == name })
    }
    
    /// Returns a scalar type with a given name if it exists.
    func scalar(name: String) -> ScalarType? {
        scalars.first(where: { $0.name == name })
    }

    // MARK: - Operations

    /// Query operation type in the schema.
    var query: Operation {
        .query(object(name: _query)!)
    }

    /// Mutation operation type in the schema.
    var mutation: Operation? {
        _mutation
            .flatMap { object(name: $0) }
            .flatMap { .mutation($0) }
    }

    /// Subscription operation type in the schema.
    var subscription: Operation? {
        _subscription
            .flatMap { object(name: $0) }
            .flatMap { .subscription($0) }
    }

    /// Returns operation types in the schema.
    var operations: [Operation] {
        [query, mutation, subscription].compactMap { $0 }
    }
    
    // MARK: - Scalars
    
    /// Returns every scalar referenced in the schema.
    var scalars: [ScalarType] {
        self.types.compactMap {
            switch $0 {
            case .scalar(let scalar):
                return scalar
            default:
                return nil
            }
        }
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
