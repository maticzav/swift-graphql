import Foundation

/// Represents a single GraphQL field.
public struct Field: Decodable, Equatable {
    public let name: String
    public let description: String?
    public let args: [InputValue]
    public let type: OutputTypeRef
    public let isDeprecated: Bool
    public let deprecationReason: String?
}

/// Represents a GraphQL type that may be used as an input value.
public struct InputValue: Decodable, Equatable {
    public let name: String
    public let description: String?
    public let type: InputTypeRef
}

/// Represents a  GraphQL enumerator case.
public struct EnumValue: Codable, Equatable {
    public let name: String
    public let description: String?
    public let isDeprecated: Bool
    public let deprecationReason: String?
}
