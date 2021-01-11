import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateOperation(
        _ identifier: String,
        for type: GraphQL.ObjectType,
        availability: String?
    ) throws -> [String] {
        /* Code */
        var code = [String]()
        
        code.append("/* \(identifier) */")
        code.append("")
        
        /* Definition*/
        availability.map { code.append($0) }
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
        availability.map { code.append($0) }
        code.append("extension Operations.\(identifier): GraphQL\(identifier) {")
        code.append("}")
        code.append("")
        
        /* Decoder */
        availability.map { code.append($0) }
        code.append("extension Operations.\(identifier): Decodable {")
        code.append(contentsOf: try generateDecodableExtension(fields: type.fields).indent(by: 4))
        code.append("}")
        code.append("")
        
        /* Fields */
        availability.map { code.append($0) }
        code.append("extension Fields where TypeLock == Operations.\(identifier) {")
        code.append(contentsOf: try type.fields.flatMap { try generateField($0) }.indent(by: 4))
        code.append("}")
        
        return code
    }
}
