import Foundation

extension GraphQL {
    public enum Scalar: Codable, Equatable {
        case id
        case string
        case boolean
        case integer
        case float
        case custom(String)
        
        // MARK: - Initializer
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            let scalar = try container.decode(String.self)
            
            switch scalar {
            case "ID":
                self = .id
            case "String":
                self = .string
            case "Boolean":
                self = .boolean
            case "Int":
                self = .integer
            case "Float":
                self = .float
            default:
                self = .custom(scalar)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue)
        }
        
        // MARK: - Calculated properties
        
        public var rawValue: String {
            switch self {
            case .id:
                return "ID"
            case .string:
                return "String"
            case .boolean:
                return "Boolean"
            case .integer:
                return "Int"
            case .float:
                return "Float"
            case .custom(let scalar):
                return scalar
            }
        }
        
        public var swiftType: String {
            switch self {
            case .id:
                return "String"
            case .string:
                return "String"
            case .boolean:
                return "Bool"
            case .integer:
                return "Int"
            case .float:
                return "Double"
            case .custom(let scalar):
                return scalar
            }
        }
        
        public var isCustom: Bool {
            switch self {
            case .custom(_):
                return true
            default:
                return false
            }
        }
    }
}
