import Foundation

/**
 This file contains code used to generate enumerators from schema.
 */

extension GraphQLCodegen {
    /// Generates an enumeration code.
    func generateEnum(_ type: GraphQL.EnumType) -> [String] {
        [ generateEnumDoc(for: type),
          "enum \(type.name.pascalCase): String, CaseIterable, Codable {",
        ] + type.enumValues.flatMap { generateEnumCase(for: $0).indent(by: 4) } +
        ["}"]
    }
    
    // MARK: - Private helpers
    
    private func generateEnumDoc(for type: GraphQL.EnumType) -> String {
        "/// \(type.description ?? "\(type.name)")"
    }

    private func generateEnumCase(for env: GraphQL.EnumValue) -> [String] {
        [ generateEnumCaseDoc(for: env),
          generateEnumCaseDeprecationDoc(for: env),
          #"case \#(env.name.camelCase.normalize) = "\#(env.name)""#,
          ""
        ]
        .compactMap { $0 }
    }
    
    private func generateEnumCaseDoc(for env: GraphQL.EnumValue) -> String? {
        env.description.map { "/// \($0)" }
    }
    
    private func generateEnumCaseDeprecationDoc(for env: GraphQL.EnumValue) -> String? {
        env.isDeprecated ? "@available(*, deprecated, message: \"\(env.deprecationReason ?? "")\")" : nil
    }
}
