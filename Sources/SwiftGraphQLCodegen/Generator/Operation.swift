import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateOperation(
        _ identifier: String,
        for type: GraphQL.ObjectType,
        operation: Operation? = nil
    ) throws -> [String] {
        let protocols = getOperationProtocols(for: operation)
        
        /* Code */
        var code = [String]()
        
        code.append("/* \(identifier) */")
        code.append("")
        
        /* Definition*/
        code.append("extension Operations {")
        code.append(contentsOf:
            try generateEncodableStruct(
                identifier,
                fields: type.fields,
                protocols: protocols
            ).indent(by: 4)
        )
        code.append("}")
        
        /* Decoder */
        code.append("extension Operations.\(identifier): Decodable {")
        code.append(contentsOf: try generateDecodableExtension(fields: type.fields))
        code.append("}")
        
        code.append("")
        /* Fields */
        code.append("extension SelectionSet where TypeLock == Operations.\(identifier) {")
        code.append(contentsOf: try type.fields.flatMap { try generateField($0) }.indent(by: 4))
        code.append("}")
        
        return code
    }
    
    // MARK: - Private helpers
    
    enum Operation: String {
        case query = "GraphQLRootQuery"
        case mutation = "GraphQLRootMutation"
    }
    
    /// Generates protocol conformance strings for the object.
    private func getOperationProtocols(for operation: Operation?) -> [String] {
        [operation?.rawValue, "Encodable"].compactMap { $0 }
    }
}
