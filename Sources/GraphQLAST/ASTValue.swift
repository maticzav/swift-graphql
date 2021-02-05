import Foundation

/* Field */
public struct Field: Decodable, Equatable {
    public let name: String
    public let description: String?
    public let args: [InputValue]
    public let type: OutputTypeRef
    public let isDeprecated: Bool
    public let deprecationReason: String?
}

/* Input value */
public struct InputValue: Decodable, Equatable {
    public let name: String
    public let description: String?
    public let type: InputTypeRef
}

/* Enum */
public struct EnumValue: Codable, Equatable {
    public let name: String
    public let description: String?
    public let isDeprecated: Bool
    public let deprecationReason: String?
}
