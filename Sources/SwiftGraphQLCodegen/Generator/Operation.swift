import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateOperation(
        _ identifier: String,
        for type: GraphQL.ObjectType,
        operation: Operation
    ) throws -> [String] {
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
                protocols: ["Encodable"]
            ).indent(by: 4)
        )
        code.append("}")
        code.append("")
        
        /* Operation*/
        code.append("extension Operations.\(identifier): GraphQLOperation {")
        code.append("    static var operation: GraphQLOperationType { \(operation.rawValue) }")
        code.append("}")
        code.append("")
        
        /* Decoder */
        code.append("extension Operations.\(identifier): Decodable {")
        code.append(contentsOf: try generateDecodableExtension(fields: type.fields).indent(by: 4))
        code.append("}")
        code.append("")
        
        /* Fields */
        code.append("extension Fields where TypeLock == Operations.\(identifier) {")
        code.append(contentsOf: try type.fields.flatMap { try generateField($0) }.indent(by: 4))
        code.append("}")
        
        return code
    }
    
    // MARK: - Private helpers
    
    enum Operation: String {
        case query = ".query"
        case mutation = ".mutation"
    }
}
