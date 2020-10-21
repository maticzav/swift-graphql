import Foundation

// MARK: - Types

enum IntrospectionTypeKind: String, Codable, Equatable {
    case scalar = "SCALAR"
    case object = "OBJECT"
    case interface = "INTERFACE"
    case union  = "UNION"
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
            let named = try Type.init(from: decoder)
            self = .named(named)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case kind = "kind"
        case name = "name"
        case ofType = "ofType"
    }
}

extension GraphQL.TypeRef: Equatable where Type: Equatable {}

extension GraphQL.TypeRef {
    /// Returns the bottom most named type in reference.
    var namedType: Type {
        switch self {
        case .named(let type):
            return type
        case .nonNull(let subRef), .list(let subRef):
            return subRef.namedType
        }
    }
}

// MARK: - Type Alias

extension GraphQL {
    typealias NamedTypeRef = TypeRef<NamedType>
    typealias OutputTypeRef = TypeRef<OutputType>
    typealias InputTypeRef = TypeRef<InputType>
}
