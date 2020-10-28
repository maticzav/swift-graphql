import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateOperation(
        _ identifier: String,
        for type: GraphQL.ObjectType,
        operation: Operation? = nil
    ) throws -> [String] {
        let protocols = generateOperationProtocols(for: operation)
        
        /* Code */
        let code = try
            [ "/* \(identifier) */",
              "",
              "extension Operations {",
              "    struct \(identifier): \(protocols) {"
            ] + type.fields.map { try generateFieldDecoder(for: $0) }.indent(by: 8) +
            [ "    }",
              "}",
              "",
              "extension SelectionSet where TypeLock == Operations.\(identifier) {"
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
    private func generateOperationProtocols(for operation: Operation?) -> String {
        [operation?.rawValue, "Codable"].compactMap { $0 }.joined(separator: ", ")
    }
}
