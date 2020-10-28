import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateObject(
        _ identifier: String,
        for type: GraphQL.ObjectType,
        operation: Operation? = nil
    ) throws -> [String] {
        let name = type.name.pascalCase
        let protocols = generateObjectProtocols(for: operation)
        
        /* Code */
        let code = try
            [ "/* \(name) */",
              "",
              "extension Objects {",
              "    struct \(name): \(protocols) {"
            ] + type.fields.map { try generateFieldDecoder(for: $0) }.indent(by: 8) +
            [ "    }",
              "}",
              "",
              "typealias \(identifier) = Objects.\(name)",
              "",
              "extension SelectionSet where TypeLock == \(identifier) {"
            ] + type.fields.flatMap { try generateField($0) }.indent(by: 4) +
            [ "}" ]
        
        return code
    }
    
    // MARK: - Private helpers
    
    enum Operation: String {
        case query = "GraphQLRootQuery"
        case mutation = "GraphQLRootMutation"
    }
    
    /// Generates protocol conformance strings for the object.
    private func generateObjectProtocols(for operation: Operation?) -> String {
        [operation?.rawValue, "Decodable"].compactMap { $0 }.joined(separator: ", ")
    }
    
    
    // MARK: - Type Name
    
    /// Generates an object type used for aliasing a phantom type.
    func generateObjectTypeLock(for typeName: String) -> String {
        "\(typeName)Object"
    }
}
