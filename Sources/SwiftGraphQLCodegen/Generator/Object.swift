import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateObject(
        _ typeName: String,
        for type: GraphQL.ObjectType,
        operation: Operation? = nil
    ) throws -> [String] {
        try
            [ "/* \(type.name) */",
              "",
              "extension Objects {",
              "    struct \(type.name.pascalCase): \(generateObjectProtocols(for: operation)) {"
            ] + type.fields.map { try generateFieldDecoder(for: $0) }.indent(by: 8) +
            [ "    }",
              "}",
              "",
              "typealias \(typeName) = Objects.\(type.name.pascalCase)",
              "",
              "extension SelectionSet where TypeLock == \(typeName) {"
            ] + type.fields.flatMap { try generateField($0) }.indent(by: 4) +
            [ "}" ]
    }
    
    // MARK: - Private helpers
    
    enum Operation: String {
        case query = "GraphQLRootQuery"
        case mutation = "GraphQLRootMutation"
    }
    
    /// Generates protocol conformance strings for the object.
    private func generateObjectProtocols(for operation: Operation?) -> String {
        [operation?.rawValue, "Codable"].compactMap { $0 }.joined(separator: ", ")
    }
    
    
    // MARK: - Type Name
    
    /// Generates an object type used for aliasing a phantom type.
    func generateObjectTypeLock(for typeName: String) -> String {
        "\(typeName)Object"
    }
}
