import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateObject(_ type: GraphQL.ObjectType) throws -> [String] {
        let name = type.name.pascalCase
        
        /* Code */
        let code = try
            [ "/* \(name) */",
              "",
              "extension Objects {",
              "    struct \(name): Codable {"
            ] + type.fields.map { try generateFieldDecoder(for: $0) }.indent(by: 8) +
            [ "    }",
              "}",
              "",
              "extension SelectionSet where TypeLock == Objects.\(name) {"
            ] + type.fields.flatMap { try generateField($0) }.indent(by: 4) +
            [ "}" ]
        
        return code
    }
}
