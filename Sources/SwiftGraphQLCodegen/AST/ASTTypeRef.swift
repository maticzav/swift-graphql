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
            case .scalar(let name),
                 .object(let name),
                 .interface(let name),
                 .union(let name),
                 .enum(let name),
                 .inputObject(let name):
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
            case .scalar(let name),
                 .object(let name),
                 .interface(let name),
                 .union(let name),
                 .enum(let name):
                return name
            }
        }
    }
    
    enum InputRef: Equatable {
        case scalar(String)
        case `enum`(String)
        case inputObject(String)
        
        var name: String {
            switch self {
            case .scalar(let name),
                 .enum(let name),
                 .inputObject(let name):
                return name
            }
        }
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
        case kind = "kind"
        case name = "name"
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
        case kind = "kind"
        case name = "name"
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
        case kind = "kind"
        case name = "name"
    }
}

// MARK: - Type Alias

extension GraphQL {
    typealias NamedTypeRef = TypeRef<NamedRef>
    typealias OutputTypeRef = TypeRef<OutputRef>
    typealias InputTypeRef = TypeRef<InputRef>
}
