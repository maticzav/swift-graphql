import Foundation

// MARK: - Types

enum IntrospectionTypeKind: String, Codable, Equatable {
    case scalar = "SCALAR"
    case object = "OBJECT"
    case interface = "INTERFACE"
    case union = "UNION"
    case enumeration = "ENUM"
    case inputObject = "INPUT_OBJECT"
    case list = "LIST"
    case nonNull = "NON_NULL"
}

// MARK: - Reference Type

extension GraphQL {
    /// Represents a GraphQL type reference.
    indirect enum TypeRef<Type> {
        case named(Type)
        case list(TypeRef)
        case nonNull(TypeRef)

        // MARK: - Calculated properties

        /// Returns the non nullable self.
        var nonNullable: TypeRef<Type> {
            inverted.nonNullable.inverted
        }

        /// Makes the type optional.
        var nullable: TypeRef<Type> {
            switch self {
            case let .nonNull(subref):
                return subref
            default:
                return self
            }
        }
    }

    // MARK: - Possible Type References

    enum NamedRef: Equatable {
        case scalar(String)
        case object(String)
        case interface(String)
        case union(String)
        case `enum`(String)
        case inputObject(String)

        var name: String {
            switch self {
            case let .scalar(name), let
                .object(name), let
                .interface(name), let
                .union(name), let
                .enum(name), let
                .inputObject(name):
                return name
            }
        }
    }

    enum ObjectRef: Equatable {
        case object(String)

        var name: String {
            switch self {
            case let .object(name):
                return name
            }
        }
    }

    enum InterfaceRef: Equatable {
        case interface(String)

        var name: String {
            switch self {
            case let .interface(name):
                return name
            }
        }
    }

    enum OutputRef: Equatable {
        case scalar(String)
        case object(String)
        case interface(String)
        case union(String)
        case `enum`(String)

        var name: String {
            switch self {
            case let .scalar(name), let
                .object(name), let
                .interface(name), let
                .union(name), let
                .enum(name):
                return name
            }
        }
    }

    enum InputRef: Equatable {
        case scalar(String)
        case `enum`(String)
        case inputObject(String)

//        var name: String {
//            switch self {
//            case .scalar(let name),
//                 .enum(let name),
//                 .inputObject(let name):
//                return name
//            }
//        }
    }
}

// MARK: - Extensions

extension GraphQL.TypeRef: Decodable where Type: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(IntrospectionTypeKind.self, forKey: .kind)

        switch kind {
        case .list:
            let ref = try container.decode(GraphQL.TypeRef<Type>.self, forKey: .ofType)
            self = .list(ref)
        case .nonNull:
            let ref = try container.decode(GraphQL.TypeRef<Type>.self, forKey: .ofType)
            self = .nonNull(ref)
        case .scalar, .object, .interface, .union, .enumeration, .inputObject:
            let named = try Type(from: decoder)
            self = .named(named)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case ofType
    }
}

extension GraphQL.TypeRef: Equatable where Type: Equatable {}

extension GraphQL.TypeRef {
    /// Returns the bottom most named type in reference.
    var namedType: Type {
        switch self {
        case let .named(type):
            return type
        case let .nonNull(subRef), let .list(subRef):
            return subRef.namedType
        }
    }
}

extension GraphQL.NamedRef: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        let name = try container.decode(String.self, forKey: .name)

        switch kind {
        case .scalar:
            self = .scalar(name)
        case .object:
            self = .object(name)
        case .interface:
            self = .interface(name)
        case .union:
            self = .union(name)
        case .enumeration:
            self = .enum(name)
        case .inputObject:
            self = .inputObject(name)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
    }
}

extension GraphQL.ObjectRef: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        let name = try container.decode(String.self, forKey: .name)

        switch kind {
        case .object:
            self = .object(name)
        default:
            throw DecodingError.typeMismatch(
                GraphQL.OutputRef.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Couldn't decode output object."
                )
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
    }
}

extension GraphQL.InterfaceRef: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        let name = try container.decode(String.self, forKey: .name)

        switch kind {
        case .interface:
            self = .interface(name)
        default:
            throw DecodingError.typeMismatch(
                GraphQL.OutputRef.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Couldn't decode output object."
                )
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
    }
}

extension GraphQL.OutputRef: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        let name = try container.decode(String.self, forKey: .name)

        switch kind {
        case .scalar:
            self = .scalar(name)
        case .object:
            self = .object(name)
        case .interface:
            self = .interface(name)
        case .union:
            self = .union(name)
        case .enumeration:
            self = .enum(name)
        default:
            throw DecodingError.typeMismatch(
                GraphQL.OutputRef.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Couldn't decode output object."
                )
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
    }
}

extension GraphQL.InputRef: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        let name = try container.decode(String.self, forKey: .name)

        switch kind {
        case .scalar:
            self = .scalar(name)
        case .enumeration:
            self = .enum(name)
        case .inputObject:
            self = .inputObject(name)
        default:
            throw DecodingError.typeMismatch(
                GraphQL.InputRef.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Couldn't decode output object."
                )
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
    }
}

// MARK: - Type Alias

extension GraphQL {
    typealias NamedTypeRef = TypeRef<NamedRef>
    typealias OutputTypeRef = TypeRef<OutputRef>
    typealias InputTypeRef = TypeRef<InputRef>
    typealias ObjectTypeRef = TypeRef<ObjectRef>
    typealias InterfaceTypeRef = TypeRef<InterfaceRef>
}
