import Foundation

/*
 Coder is responsible for generating an intermediate type that
 generated code uses to decode the response.

 We first decode the key that references a result and use the type
 engraved in the alias to further decode the result. The result is
 saved into a HashMap structure that groups fields with the same type
 and extract a dictionary of results from it.
 */

extension GraphQLCodegen {
    /// Generates a struct that is used as an intermediate decoder and encoder in generated code.
    func generateEncodableStruct(
        _ name: String,
        fields: [GraphQL.Field],
        protocols: [String],
        possibleTypes: [GraphQL.ObjectRef]? = nil
    ) throws -> [String] {
        /* Code */
        var code = [String]()

        code.append("struct \(name): \(protocols.joined(separator: ", ")) {")
        code.append("")
        code.append("/* \(name) */")

        /* TypeName */
        if let possibleTypes = possibleTypes {
            /* TypeName enum */
            code.append("enum TypeName: String, Codable {")
            code.append(contentsOf: possibleTypes.map {
                "case \($0.name.camelCase.normalize) = \"\($0.name)\""
            })
            code.append("}")
        }

        /* Properties */
        code.append("")
        code.append("/* Properties */")

        if possibleTypes != nil {
            /* Typename field decoder */
            code.append("let __typename: TypeName")
        }

        /* Internal fields */
        code.append(contentsOf: try fields.map {
            let type = generateDecoderType(try generateOutputType(ref: $0.type.namedType), for: $0.type.nonNullable)
            return "let \($0.name.camelCase.normalize): [String: \(type)]"
        })

        code.append("}")

        return code
    }

    func generateDecodableExtension(
        fields: [GraphQL.Field],
        possibleTypes: [GraphQL.ObjectRef]? = nil
    ) throws -> [String] {
        var code = [String]()

        /* Decoder */
        code.append("")
        code.append("/* Decoder */")
        code.append(contentsOf: try generateDecoder(for: fields, initTypename: possibleTypes != nil))
        code.append("")
        code.append(contentsOf: dynamicCodingKeysStruct)

        return code
    }

    // MARK: - Private helpers

    private func generateDecoder(for fields: [GraphQL.Field], initTypename: Bool) throws -> [String] {
        var code = [String]()
        code.append(contentsOf: [
            "init(from decoder: Decoder) throws {",
            "    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)",
            "",
            "",
            "    var map = HashMap()",
            "    for codingKey in container.allKeys {",
            "        if codingKey.isTypenameKey { continue }",
            "",
            "        let alias = codingKey.stringValue",
            "        let field = GraphQLField.getFieldNameFromAlias(alias)",
            "",
            "        switch field {",
        ])
        code.append(contentsOf: try fields.flatMap { try generateDecoderForField($0) })
        code.append(contentsOf: [
            "            default:",
            "                throw DecodingError.dataCorrupted(",
            "                    DecodingError.Context(",
            "                        codingPath: decoder.codingPath,",
            "                        debugDescription: \"Unknown key \\(field).\"",
            "                    )",
            "                )",
            "        }",
            "    }",
            "",
        ])

        /* Property setters */
        if initTypename {
            code.append("self.__typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: \"__typename\")!)")
        }
        code.append(contentsOf: fields.map {
            "self.\($0.name.camelCase) = map[\"\($0.name.camelCase)\"]"
        })
        code.append("}")

        return code
    }

    private func generateDecoderForField(_ field: GraphQL.Field) throws -> [String] {
        let type = try generateOutputType(ref: field.type.namedType)
        let decoderType = generateDecoderType(type, for: field.type.nullable)

        return [
            "case \"\(field.name.camelCase)\":",
            "    if let value = try container.decode(\(decoderType).self, forKey: codingKey) {",
            "        map.set(key: field, hash: alias, value: value as Any)",
            "    }",
        ]
    }

    private var dynamicCodingKeysStruct: [String] {
        ["private struct DynamicCodingKeys: CodingKey {",
         "    // Use for string-keyed dictionary",
         "    var stringValue: String",
         "    init?(stringValue: String) {",
         "        self.stringValue = stringValue",
         "    }",
         "",
         "    // Use for integer-keyed dictionary",
         "    var intValue: Int?",
         "    init?(intValue: Int) { nil }",
         "}"]
    }
}
