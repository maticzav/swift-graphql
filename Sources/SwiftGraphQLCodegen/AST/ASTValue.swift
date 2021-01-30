import Foundation

extension GraphQL {
    /* Field */
    struct Field: Decodable, Equatable {
        let name: String
        let description: String?
        let args: [InputValue]
        let type: OutputTypeRef
        let isDeprecated: Bool
        let deprecationReason: String?
    }
    
    /* Input value */
    struct InputValue: Decodable, Equatable {
        let name: String
        let description: String?
        let type: InputTypeRef
    }
    
    /* Enum */
    struct EnumValue: Codable, Equatable {
        let name: String
        let description: String?
        let isDeprecated: Bool
        let deprecationReason: String?
    }
}
