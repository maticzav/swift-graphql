import Foundation

extension GraphQLCodegen {
    
    // MARK: - Field Decoders
    
    func generateFieldDecoder(for field: GraphQL.Field) -> String {
        // Make the type optional.
        var nullableType = field.type
        switch nullableType {
        case .nonNull(let subref):
            nullableType = subref
        default:
            ()
        }
        
        // Generate decoder.
        switch field.type.inverted.namedType {
        /* Scalar */
        case .scalar(let scalar):
            return "let \(field.name): \(generateDecoderType(options.scalar(scalar), for: nullableType))"
        /* Enumerator */
        case .enum(let enm):
            return "let \(field.name): \(generateDecoderType(enm, for: nullableType))"
        /* Selections */
        case .object(let type), .interface(let type), .union(let type):
            return "let \(field.name): \(generateDecoderType(type.pascalCase, for: nullableType))"
        }
    }
    
    // MARK: - Field Selection
    
    /// Generates a SwiftGraphQL field.
    func generateField(_ field: GraphQL.Field) -> String {
        let lines: [String?] = [
            generateFieldDoc(for: field),
            generateFieldDeprecationDoc(for: field),
            "func \(generateFnDefinition(for: field)) -> \(generateReturnType(for: field.type)) {",
            "    /* Selection */"
        ]
        + generateFieldSelection(for: field).map { "    \($0)" }
        + [ "    self.select(field)",
            "",
            "    /* Decoder */",
            "    if let data = self.response {",
            "        return \(generateDecoder(for: field))",
            "    }",
            "    return \(generateMockData(for: field.type))",
            "}"
        ]
        
        
        return lines.compactMap { $0 }.map { "    \($0)"}.joined(separator: "\n")
    }
    
    // MARK: - Documentation
    
    /// Generates field documentation.
    private func generateFieldDoc(for field: GraphQL.Field) -> String? {
        field.description.map { "/// \($0)" }
    }
    
    /// Generates deprecation documentation.
    private func generateFieldDeprecationDoc(for field: GraphQL.Field) -> String? {
        field.isDeprecated ? "@available(*, deprecated, message: \"\(field.deprecationReason ?? "")\")" : nil
    }
    
    // MARK: - Function definition

    /// Generates a function definition for a field.
    private func generateFnDefinition(for field: GraphQL.Field) -> String {
        switch field.type.namedType {
        /* Scalar, Enum */
        case .scalar(_), .enum(_):
            return "\(field.name.camelCase)(\(generateFnArguments(for: field.args)))"
        /* Selections */
        case .interface(_), .object(_), .union(_):
            let typeLock = generateObjectTypeLock(for: field.type.namedType.name.pascalCase)
            let decoderType = generateDecoderType(typeLock, for: field.type)
            // Function generator
            if field.args.isEmpty {
                return "\(field.name.camelCase)<Type>(_ selection: Selection<Type, \(decoderType)>)"
            }
            return "\(field.name.camelCase)<Type>(\(generateFnArguments(for: field.args)), _ selection: Selection<Type, \(decoderType)>)"
        }
    }
    
    /// Generates arguments for accessor function.
    private func generateFnArguments(for args: [GraphQL.InputValue]) -> String {
        args.map { generateArgument(for: $0) }.joined(separator: ", ")
    }
    
    /// Generates a function parameter based on an input value.
    private func generateArgument(for input: GraphQL.InputValue) -> String {
        "\(input.name.camelCase): \(generateArgumentType(for: input.type))"
    }
    
    /// Generates a type definition for an argument function parameter.
    private func generateArgumentType(for ref: GraphQL.InputTypeRef) -> String {
        switch ref.namedType {
        case .scalar(let scalar):
            return generateDecoderType(options.scalar(scalar), for: ref)
        case .enum(let enm):
            return generateDecoderType(enm, for: ref)
        case .inputObject(let inputObject):
            return generateDecoderType(inputObject.pascalCase, for: ref)
        }
    }

    /// Recursively generates a return type of a referrable type.
    private func generateReturnType(for ref: GraphQL.OutputTypeRef) -> String {
        switch ref.namedType {
        case .scalar(let scalar):
            return generateDecoderType(options.scalar(scalar), for: ref)
        case .enum(let enm):
            return generateDecoderType(enm, for: ref)
        case .interface(_),
            .object(_),
            .union(_):
            return "Type"
        }
    }
    
    // Generates an intermediate type used in custom decoders to cast JSON representation of the data.
    private func generateDecoderType<Ref>(_ typeName: String, for ref: GraphQL.TypeRef<Ref>) -> String {
        generateDecoderType(typeName, for: ref.inverted)
    }

    /// Generates an intermediate type used in custom decoders to cast JSON representation of the data.
    private func generateDecoderType<Ref>(_ typeName: String, for ref: GraphQL.InvertedTypeRef<Ref>) -> String {
        switch ref {
        case .named(_):
            return typeName
        case .list(let subRef):
            return "[\(generateDecoderType(typeName, for: subRef))]"
        case .nullable(let subRef):
            return "\(generateDecoderType(typeName, for: subRef))?"
        }
    }
    
    // MARK: - Selection

    /// Generates an internal leaf definition used for composing selection set.
    private func generateFieldSelection(for field: GraphQL.Field) -> [String] {
        switch field.type.namedType {
        case .scalar(_), .enum(_):
            return
                [ "let field = GraphQLField.leaf(",
                  "    name: \"\(field.name)\",",
                  "    arguments: [",
                  generateSelectionArguments(for: field.args).map { "        \($0)" }.joined(separator: "\n"),
                  "    ]",
                  ")"
                ]
        case .interface(_), .object(_), .union(_):
            return
                [ "let field = GraphQLField.composite(",
                  "    name: \"\(field.name)\",",
                  "    arguments: [",
                  generateSelectionArguments(for: field.args).map { "        \($0)" }.joined(separator: "\n"),
                  "    ],",
                  "    selection: selection.selection",
                  ")"
                ]
        }
    }
    
    /// Generates a dictionary of argument builders.
    private func generateSelectionArguments(for args: [GraphQL.InputValue]) -> [String] {
        args.map { #"Argument(name: "\#($0.name)", value: \#($0.name)),"# }
    }
    
    // MARK: - Accessors

    /// Generates a field decoder.
    private func generateDecoder(for field: GraphQL.Field) -> String {
        switch field.type.inverted.namedType {
        /* Scalar, Enumeration */
        case .scalar(_), .enum(_):
            switch field.type.inverted {
            case .nullable(_):
                return "data.\(field.name)"
            default:
                return "data.\(field.name)!"
            }
        /* Selections */
        case .interface(_), .object(_), .union(_):
            switch field.type.inverted {
            case .nullable(_):
                return "data.\(field.name).map { selection.decode(data: $0) } ?? selection.mock()"
            default:
                return "selection.decode(data: data.\(field.name)!)"
            }
        }
    }
    
    // MARK: - Mocking

    /// Generates value placeholders for the API.
    private func generateMockData(for ref: GraphQL.OutputTypeRef) -> String {
        switch ref.namedType {
        /* Scalars */
        case .scalar(let scalar):
            return generateMockWrapper("\(options.scalar(scalar)).mockValue", for: ref)
        /* Enumerations */
        case .enum(let enm):
            return generateMockWrapper("\(enm).allCases.first!", for: ref)
        /* Selections */
        case .interface(_), .object(_), .union(_):
            return "selection.mock()"
        }
    }
    
    /// Generates the mock value for wrapped type.
    private func generateMockWrapper(_ value: String, for ref: GraphQL.OutputTypeRef) -> String {
        generateMockWrapper(value, for: ref.inverted)
    }
    
    /// Generates the mock value for wrapped type.
    private func generateMockWrapper(_ value: String, for ref: GraphQL.InvertedOutputTypeRef) -> String {
        switch ref {
        case .named(_):
            return value
        case .list(_):
            return "[]"
        case .nullable(_):
            return "nil"
        }
    }
}
