import Foundation

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
        code.append("/* \(name) */".indent(by: 4))
        
        /* TypeName */
        if let possibleTypes = possibleTypes {
            /* TypeName enum */
            code.append("enum TypeName: String, Codable {".indent(by: 4))
            code.append(contentsOf: possibleTypes.map {
                "case \($0.name.camelCase) = \"\($0.name)\"".indent(by: 8)
            })
            code.append("}".indent(by: 4))
        }
        
        /* Properties */
        code.append("")
        code.append("/* Properties */".indent(by: 4))
        
        if possibleTypes != nil {
            /* Typename field decoder */
            code.append("let __typename: TypeName".indent(by: 4))
        }
        
        /* Internal fields */
        code.append(contentsOf: try fields.map {
            let type = generateDecoderType(try generateOutputType(ref: $0.type.namedType), for: $0.type.nonNullable)
            return "let \($0.name.normalize): [String: \(type)]"
        }.indent(by: 4))
        
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
        code.append(contentsOf: dynamicCodingKeysStruct.indent(by: 4))
        
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
            "        switch field {"
        ])
        code.append(contentsOf: try fields.flatMap { try generateDecoderForField($0) }.indent(by: 12))
        code.append(contentsOf:[
            "            default:",
            "                throw DecodingError.dataCorrupted(",
            "                    DecodingError.Context(",
            "                        codingPath: decoder.codingPath,",
            "                        debugDescription: \"Unknown key \\(field).\"",
            "                    )",
            "                )",
            "        }",
            "    }",
            ""
        ])
        
        /* Property setters */
        if initTypename {
            code.append("self.__typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: \"__typename\")!)".indent(by: 4))
        }
        code.append(contentsOf: fields.map {
            "self.\($0.name.camelCase) = map[\"\($0.name.camelCase)\"]"
        }.indent(by: 4))
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
            "    }"
        ]
    }
    
    private var dynamicCodingKeysStruct: [String] {
        [ "private struct DynamicCodingKeys: CodingKey {",
          "    // Use for string-keyed dictionary",
          "    var stringValue: String",
          "    init?(stringValue: String) {",
          "        self.stringValue = stringValue",
          "    }",
          "",
          "    // Use for integer-keyed dictionary",
          "    var intValue: Int?",
          "    init?(intValue: Int) { nil }",
          "}"
        ]
    }
}


