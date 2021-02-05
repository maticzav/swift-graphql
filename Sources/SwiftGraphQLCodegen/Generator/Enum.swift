import Foundation
import GraphQLAST

/*
 We represent enumerator values as strings. There's nothing
 special in here, just the generated code.
 */

extension GraphQLCodegen {
    /// Generates an enumeration code.
    func generateEnum(_ type: EnumType) -> [String] {
        [generateEnumDoc(for: type),
         "enum \(type.name.pascalCase): String, CaseIterable, Codable {"] + type.enumValues.flatMap { generateEnumCase(for: $0) } +
            ["}"]
    }

    // MARK: - Private helpers

    private func generateEnumDoc(for type: EnumType) -> String {
        "/// \(type.description ?? "\(type.name)")"
    }

    private func generateEnumCase(for env: EnumValue) -> [String] {
        [generateEnumCaseDoc(for: env),
         generateEnumCaseDeprecationDoc(for: env),
         #"case \#(env.name.camelCase.normalize) = "\#(env.name)""#,
         ""]
            .compactMap { $0 }
    }

    private func generateEnumCaseDoc(for env: EnumValue) -> String? {
        env.description.map { "/// \($0)" }
    }

    private func generateEnumCaseDeprecationDoc(for env: EnumValue) -> String? {
        env.isDeprecated ? "@available(*, deprecated, message: \"\(env.deprecationReason ?? "")\")" : nil
    }
}
