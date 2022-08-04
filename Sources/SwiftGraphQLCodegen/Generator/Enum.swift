import Foundation
import GraphQLAST
import SwiftGraphQLUtils

extension EnumType {
    
    /// Represents the enum structure.
    var declaration: String {
        """
        extension Enums {
            \(docs)
            enum \(name.pascalCase): String, CaseIterable, Codable {
            \(values)
            }
        }
        
        extension Enums.\(name.pascalCase): GraphQLScalar {
            \(decode)
        
            \(mock)
        }
        """
    }
    
    // MARK: - Definition

    private var docs: String {
        (description ?? name).split(separator: "\n").map { "/// \($0)" }.joined(separator: "\n")
    }

    /// Represents possible enum cases.
    private var values: String {
        enumValues.map { $0.declaration }.joined(separator: "\n")
    }
    
    // MARK: - GraphQL Scalar
    
    private var decode: String {
        return """
            init(from data: AnyCodable) throws {
                switch data.value {
                case let string as String:
                    if let value = Enums.\(self.name.pascalCase)(rawValue: string) {
                        self = value
                    } else {
                        throw ScalarDecodingError.unknownEnumCase(value: string)
                    }
                default:
                    throw ScalarDecodingError.unexpectedScalarType(
                            expected: "\(self.name)",
                            received: data.value
                    )
                }
            }
            """
    }
    
    /// Mock value declaration.
    private var mock: String {
        let value = self.enumValues.first!
        return "static var mockValue = Self.\(value.name.camelCase.normalize)"
    }
}

// MARK: - EnumValue

extension EnumValue {
    
    /// Returns an enum case definition.
    fileprivate var declaration: String {
        """
        \(docs)
        case \(name.camelCase.normalize) = "\(name)"
        """
    }

    private var docs: String {
        if let description = self.description {
            return description.split(separator: "\n").map { "/// \($0)" }.joined(separator: "\n")
        }
        return ""
    }
}
