import Foundation

enum NamedTypeKind: String, Codable, Equatable {
    case scalar = "SCALAR"
    case object = "OBJECT"
    case interface = "INTERFACE"
    case union  = "UNION"
    case enumeration = "ENUM"
    case inputObject = "INPUT_OBJECT"
}


protocol NamedTypeProtocol {
    var kind: NamedTypeKind { get }
    var name: String { get }
    var description: String? { get }
}

// MARK: - Type Extensions

extension NamedTypeProtocol {
    var isInternal: Bool {
        name.starts(with: "__")
    }
}

// MARK: - Named Types

extension GraphQL {
    /* Scalar */
    struct ScalarType: NamedTypeProtocol, Decodable, Equatable {
        var kind: NamedTypeKind = .scalar
        let name: String
        let description: String?
    }
    
    /* Object */
    struct ObjectType: NamedTypeProtocol, Decodable, Equatable {
        var kind: NamedTypeKind = .object
        let name: String
        let description: String?
        
        let fields: [Field]
        let interfaces: [InterfaceTypeRef]
    }
    
    /* Interface */
    struct InterfaceType: NamedTypeProtocol, Decodable, Equatable {
        var kind: NamedTypeKind = .interface
        let name: String
        let description: String?
        
        let fields: [Field]
        let interfaces: [InterfaceTypeRef]
        let possibleTypes: [ObjectTypeRef]
    }
    
    /* Union */
    struct UnionType: NamedTypeProtocol, Decodable, Equatable {
        var kind: NamedTypeKind = .union
        let name: String
        let description: String?
        
        let possibleTypes: [ObjectTypeRef]
    }
    
    /* Enum */
    struct EnumType: NamedTypeProtocol, Decodable, Equatable {
        var kind: NamedTypeKind = .enumeration
        let name: String
        let description: String?
        
        let enumValues: [EnumValue]
    }
    
    /* Input Object */
    struct InputObjectType: NamedTypeProtocol, Decodable, Equatable {
        var kind: NamedTypeKind = .inputObject
        let name: String
        let description: String?
        
        let inputFields: [InputValue]
    }
}

// MARK: - Collection Types

extension GraphQL {
    enum NamedType: Equatable {
        case scalar(GraphQL.ScalarType)
        case object(GraphQL.ObjectType)
        case interface(GraphQL.InterfaceType)
        case union(GraphQL.UnionType)
        case `enum`(GraphQL.EnumType)
        case inputObject(GraphQL.InputObjectType)
    }
}

// MARK: - Decoder Initializer

extension GraphQL.NamedType: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        
        switch kind {
        case .scalar:
            let value = try GraphQL.ScalarType.init(from: decoder)
            self = .scalar(value)
        case .object:
            let value = try GraphQL.ObjectType.init(from: decoder)
            self = .object(value)
        case .interface:
            let value = try GraphQL.InterfaceType.init(from: decoder)
            self = .interface(value)
        case .union:
            let value = try GraphQL.UnionType.init(from: decoder)
            self = .union(value)
        case .enumeration:
            let value = try GraphQL.EnumType.init(from: decoder)
            self = .enum(value)
        case .inputObject:
            let value = try GraphQL.InputObjectType.init(from: decoder)
            self = .inputObject(value)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case kind = "kind"
    }
}

