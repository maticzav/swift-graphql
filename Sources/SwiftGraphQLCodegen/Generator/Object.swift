import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateObject(_ typeName: String, for type: GraphQL.ObjectType) -> [String] {
        [ "/* \(type.name) */",
          "",
          "extension Objects {",
          "    struct \(type.name.pascalCase): Codable {"
        ] + type.fields.map { generateFieldDecoder(for: $0) }.indent(by: 8) +
        [ "    }",
          "}",
          "",
          "typealias \(typeName) = Objects.\(type.name.pascalCase)",
          "",
          "extension SelectionSet where TypeLock == \(typeName) {"
        ] + type.fields.flatMap(generateField).indent(by: 4) +
        [ "}" ]
    }
    
    
    
    // MARK: - Type Name
    
    /// Generates an object type used for aliasing a phantom type.
    func generateObjectTypeLock(for typeName: String) -> String {
        "\(typeName)Object"
    }
}
