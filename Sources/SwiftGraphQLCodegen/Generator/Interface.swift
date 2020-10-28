import Foundation

/**
 Interfaces generates an object type as well as possible type extensions.
 */

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateInterface(
        _ type: GraphQL.InterfaceType,
        with objects: [GraphQL.ObjectType]
    ) throws -> [String] {
        let name = type.name.pascalCase
        
        /* Collect of all fields of all possible types. */
        var fields: [GraphQL.Field] = type.fields
        for object in objects {
            // Skip object if it's not inside possible types.
            guard type.possibleTypes.contains(where: { $0.namedType.name == object.name }) else { continue }
            // Append fields otherwise.
            for field in object.fields {
                // Make suer fields are unique.
                guard !fields.contains(where: { $0.name == field.name }) else { continue }
                fields.append(field)
            }
        }
        
        /* Code */
        var code: [String] = [
            "/* \(type.name) */",
            "",
            "extension Interfaces {",
            "    struct \(name): Codable {",
            "        let __typename: TypeName",
        ]
        code.append(contentsOf: try fields.map { try generateFieldDecoder(for: $0) }.indent(by: 8))
        code.append(contentsOf: [
            "",
            "enum TypeName: String, Codable {".indent(by: 8),
        ])
        code.append(contentsOf: type.possibleTypes.map { "case \($0.namedType.name.camelCase) = \"\($0.namedType.name)\"" }.indent(by: 12))
        code.append(contentsOf: [
            "        }",
            "    }",
            "}",
            "",
            "extension SelectionSet where TypeLock == Interfaces.\(name) {",
        ])
        code.append(contentsOf:  try type.fields.flatMap { try generateField($0) }.indent(by: 4))
        code.append(contentsOf: [
            "}",
            "",
        ])
        code.append(contentsOf: generateFragmentSelection(for: type, with: objects))
        
        return code
    }
    
    // MARK: - Private helpers
    
    private func generateFragmentSelection(
        for type: GraphQL.InterfaceType,
        with objects: [GraphQL.ObjectType]
    ) -> [String] {
        let name = type.name.pascalCase
        
        let parameters: [String] = type.possibleTypes.indexMap { (index, element) in
            let isLast = index == type.possibleTypes.count - 1
            // Last parameter to a function shouldn't have a comma.
            return "\(generateFnParameter(for: element))\(isLast ? "" : ",")"
        }
        let selection: [String] =
            [ "/* Selection */",
              "self.select([",
            ] + type.possibleTypes.map { generateFragmentSelection(for: $0) }.indent(by: 4) +
            [ "])" ]
        let decoder: [String] =
            [ "/* Decoder */",
              "if let data = self.response {",
              "    switch data.__typename {"
            ] + type.possibleTypes.flatMap { generateTypeDecoder(for: $0, with: objects) }.indent(by: 4) +
            [
              "    }",
              "}",
              "",
              "return \(type.possibleTypes.first!.namedType.name.camelCase).mock()"
            ]
        
        /* Code */
        var code = [
            "extension SelectionSet where TypeLock == Interfaces.\(name) {",
            "    func on<Type>(",
        ]
        code.append(contentsOf: parameters.indent(by: 8))
        code.append("    ) -> Type {")
        code.append(contentsOf: selection.indent(by: 8))
        code.append(contentsOf: decoder.indent(by: 8))
        code.append("    }")
        code.append("}")
        
        return code
    }
    
    private func generateFnParameter(for ref: GraphQL.ObjectTypeRef) -> String {
        "\(ref.namedType.name.camelCase): Selection<Type, Objects.\(ref.namedType.name.pascalCase)>"
    }
    
    private func generateTypeDecoder(
        for ref: GraphQL.ObjectTypeRef,
        with objects: [GraphQL.ObjectType]
    ) -> [String] {
        let name = ref.namedType.name
        let object = objects.first { $0.name == name }!
        
        /* Code */
        var code: [String] = [
            "case .\(name.camelCase):",
            "    let data = Objects.\(name.pascalCase)(",
        ]
        code.append(contentsOf: object.fields.indexMap { (index, element) in
            let name = element.name.camelCase
            let isLast = index == object.fields.count - 1
            // The last parameter shouldn't have a comma.
            return "\(name): data.\(name)\(isLast ? "" : ",")"
        }.indent(by: 8))
        code.append(contentsOf: [
            "    )",
            "    return \(name.camelCase).decode(data: data)"
        ])
        
        return code
    }
    
    private func generateFragmentSelection(for ref: GraphQL.ObjectTypeRef) -> String {
        "GraphQLField.fragment(type: \"\(ref.namedType.name)\", selection: \(ref.namedType.name.camelCase).selection),"
    }
}
