import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateObject(_ type: GraphQL.ObjectType) throws -> [String] {
        let name = type.name.pascalCase

        /* Code */
        var code = [String]()

        code.append("/* \(name) */")
        code.append("")

        /* Definition*/
        code.append("extension Objects {")
        code.append(contentsOf:
            try generateEncodableStruct(
                name,
                fields: type.fields,
                protocols: ["Encodable"]
            )
        )
        code.append("}")

        /* Decoder */
        code.append("extension Objects.\(name): Decodable {")
        code.append(contentsOf: try generateDecodableExtension(fields: type.fields))
        code.append("}")

        code.append("")
        /* Fields */
        code.append("extension Fields where TypeLock == Objects.\(name) {")
        code.append(contentsOf: try type.fields.flatMap { try generateField($0) })
        code.append("}")

        return code
    }
}
