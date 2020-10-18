import Foundation

/**
 This file contains code used to generate enumerators from schema.
 */

extension GraphQLCodegen {
    /* Enums */

    /// Generates an enumeration code.
    static func generateEnum(_ type: GraphQL.FullType) -> String {
        let cases = type.enumValues ?? []
        return """
        enum \(type.name): String, CaseIterable, Codable {
        \(cases.map(generateEnumCase).joined(separator: "\n\n"))
        }
        """
    }

    private static func generateEnumCase(_ env: GraphQL.EnumValue) -> String {
        """
            case \(env.name) = \"\(env.name)\"
        """
    }
}
