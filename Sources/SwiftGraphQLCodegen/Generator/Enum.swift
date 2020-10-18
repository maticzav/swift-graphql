import Foundation

/**
 This file contains code used to generate enumerators from schema.
 */

extension GraphQLCodegen {
    /// Generates an enumeration code.
    static func generateEnum(_ type: GraphQL.FullType) -> String {
        """
        \(generateEnumDoc(for: type))
        enum \(type.name): String, CaseIterable, Codable {
        \((type.enumValues ?? []).map { generateEnumCase(for: $0) }.joined(separator: "\n\n"))
        }
        """
    }
    
    // MARK: - Private helpers
    
    private static func generateEnumDoc(for type: GraphQL.FullType) -> String {
        "/// \(type.description ?? "\(type.name)")"
    }

    private static func generateEnumCase(for env: GraphQL.EnumValue) -> String {
        """
            \(generateEnumCaseDoc(for: env))
            \(generateEnumCaseDeprecationDoc(for: env))
            case \(env.name.camelCase) = \"\(env.name)\"
        """
    }
    
    private static func generateEnumCaseDoc(for env: GraphQL.EnumValue) -> String {
        "/// \(env.description ?? "\(env.name)")"
    }
    
    private static func generateEnumCaseDeprecationDoc(for env: GraphQL.EnumValue) -> String {
        env.isDeprecated ? "@available(*, deprecated, message: \"\(env.deprecationReason ?? "")\")" : ""
    }
}
