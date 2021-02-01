import Foundation

/*
 Each field decoder contains a selection part that is responsible for
 telling the Selection about its existance and a decoder part that
 checks for the result and returns it as a function value.

 The last part of the function is a mock value which we use as a placeholder
 of the return value on the first run when we collect the selection.
 */

extension GraphQLCodegen {
    // MARK: - Field Selection

    /// Generates a SwiftGraphQL field.
    func generateField(_ field: GraphQL.Field) throws -> [String] {
        var lines = [String]()

        // Documentation.
        if let docs = generateFieldDoc(for: field) {
            lines.append(docs)
        }
        if let deprecationDocs = generateFieldDeprecationDoc(for: field) {
            lines.append(deprecationDocs)
        }

        // Field method.
        lines.append("func \(try generateFnDefinition(for: field)) throws -> \(try generateReturnType(for: field.type)) {")
        lines.append("    /* Selection */")
        lines.append(contentsOf: generateFieldSelection(for: field).indent(by: 4))
        lines.append("    self.select(field)")
        lines.append("")
        lines.append("    /* Decoder */")
        lines.append("    switch self.response {")
        lines.append("    case .decoding(let data):")
        lines.append(contentsOf: generateDecoder(for: field).indent(by: 8))
        lines.append("    case .mocking:")
        lines.append("        return \(try generateMockData(for: field.type))")
        lines.append("    }")
        lines.append("}")

        return lines
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
    private func generateFnDefinition(for field: GraphQL.Field) throws -> String {
        let fnName = field.name.camelCase.normalize

        /* Kinds of fields. */
        switch field.type.namedType {
        /* Scalar, Enum */
        case .scalar(_), .enum:
            let arguments = try generateFnParameters(for: field.args)
            return "\(fnName)(\(arguments))"
        /* Selections */
        case let .object(typeLock):
            let type = "Objects.\(typeLock.pascalCase)"
            let decoderType = generateDecoderType(type, for: field.type)
            return try generateFnDefinitionWithSelection(
                name: fnName,
                args: field.args,
                decoderType: decoderType
            )
        case let .interface(typeLock):
            let typeLock = "Interfaces.\(typeLock.pascalCase)"
            let decoderType = generateDecoderType(typeLock, for: field.type)
            return try generateFnDefinitionWithSelection(
                name: fnName,
                args: field.args,
                decoderType: decoderType
            )
        case let .union(typeLock):
            let typeLock = "Unions.\(typeLock.pascalCase)"
            let decoderType = generateDecoderType(typeLock, for: field.type)
            return try generateFnDefinitionWithSelection(
                name: fnName,
                args: field.args,
                decoderType: decoderType
            )
        }
    }

    /// Returns a string representation of function defenition that has selection and might have arguments.
    private func generateFnDefinitionWithSelection(
        name: String,
        args: [GraphQL.InputValue],
        decoderType: String
    ) throws -> String {
        /* Function without arguments. */
        if args.isEmpty {
            return "\(name)<Type>(_ selection: Selection<Type, \(decoderType)>)"
        }
        /* Function with arguments. */
        let parameters = try generateFnParameters(for: args)
        return "\(name)<Type>(\(parameters), _ selection: Selection<Type, \(decoderType)>)"
    }

    /// Generates arguments for accessor function.
    private func generateFnParameters(for args: [GraphQL.InputValue]) throws -> String {
        try args.map { try generateParameter(for: $0) }.joined(separator: ", ")
    }

    /// Generates a function parameter based on an input value.
    private func generateParameter(for input: GraphQL.InputValue) throws -> String {
        switch input.type.inverted {
        case .nullable:
            return "\(input.name.camelCase.normalize): \(try generatePropertyType(for: input.type)) = .absent"
        default:
            return "\(input.name.camelCase.normalize): \(try generatePropertyType(for: input.type))"
        }
    }

//    /// Generates a type definition for an argument function parameter.
//    private func generateParameterType(for ref: GraphQL.InputTypeRef) throws -> String {
//        switch ref.namedType {
//        case .scalar(let scalar):
//            let scalar = try options.scalar(scalar)
//            return generatePropertyType(scalar, for: ref)
//        case .enum(let enm):
//            let type = "Enums.\(enm.pascalCase)"
//            return generatePropertyType(type, for: ref)
//        case .inputObject(let inputObject):
//            let type = "InputObjects.\(inputObject.pascalCase)"
//            return generatePropertyType(type, for: ref)
//        }
//    }

    /// Recursively generates a return type of a referrable type.
    private func generateReturnType(for ref: GraphQL.OutputTypeRef) throws -> String {
        switch ref.namedType {
        case let .scalar(scalar):
            let scalar = try options.scalar(scalar)
            return generateDecoderType(scalar, for: ref)
        case let .enum(enm):
            let type = "Enums.\(enm.pascalCase)"
            return generateDecoderType(type, for: ref)
        case .interface(_),
             .object(_),
             .union:
            return "Type"
        }
    }

    // Generates an intermediate type used in custom decoders to cast JSON representation of the data.
    func generateDecoderType<Ref>(_ typeName: String, for ref: GraphQL.TypeRef<Ref>) -> String {
        generateDecoderType(typeName, for: ref.inverted)
    }

    /// Generates an intermediate type used in custom decoders to cast JSON representation of the data.
    private func generateDecoderType<Ref>(_ typeName: String, for ref: GraphQL.InvertedTypeRef<Ref>) -> String {
        switch ref {
        case .named:
            return typeName
        case let .list(subRef):
            return "[\(generateDecoderType(typeName, for: subRef))]"
        case let .nullable(subRef):
            return "\(generateDecoderType(typeName, for: subRef))?"
        }
    }

    // MARK: - Selection

    /// Generates an internal leaf definition used for composing selection set.
    private func generateFieldSelection(for field: GraphQL.Field) -> [String] {
        switch field.type.namedType {
        case .scalar(_), .enum:
            return
                ["let field = GraphQLField.leaf(",
                 "    name: \"\(field.name)\",",
                 "    arguments: ["] + generateSelectionArguments(for: field.args).indent(by: 8) +
                ["    ]",
                 ")"]
        case .interface(_), .object(_), .union:
            return
                ["let field = GraphQLField.composite(",
                 "    name: \"\(field.name)\",",
                 "    arguments: ["] + generateSelectionArguments(for: field.args).indent(by: 8) +
                ["    ],",
                 "    selection: selection.selection",
                 ")"]
        }
    }

    /// Generates a dictionary of argument builders.
    private func generateSelectionArguments(for args: [GraphQL.InputValue]) -> [String] {
        args.map { #"Argument(name: "\#($0.name.camelCase)", type: "\#(generateArgumentType(for: $0.type))", value: \#($0.name.camelCase.normalize)),"# }
    }

    /// Generates a GraphQL acceptable type of an argument.
    private func generateArgumentType(for ref: GraphQL.InputTypeRef) -> String {
        switch ref {
        /* Named Type */
        case let .named(named):
            switch named {
            case let .enum(name), let .inputObject(name), let .scalar(name):
                return name
            }
        /* Wrappers */
        case let .list(subref):
            return "[\(generateArgumentType(for: subref))]"
        case let .nonNull(subref):
            return "\(generateArgumentType(for: subref))!"
        }
    }

    // MARK: - Accessors

    /// Generates a field decoder.
    private func generateDecoder(for field: GraphQL.Field) -> [String] {
        let name = field.name.camelCase

        switch field.type.inverted.namedType {
        /* Scalar, Enumeration */
        case .scalar(_), .enum:
            switch field.type.inverted {
            case .nullable:
                /*
                 When decoding a nullable scalar, we just return the value.
                 */
                return ["return data.\(name)[field.alias!]"]
            default:
                /*
                 In list value and non-optional scalars we want to make sure that value is present.
                 */
                return [
                    "if let data = data.\(name)[field.alias!] {",
                    "    return data",
                    "}",
                    "throw SG.HttpError.badpayload",
                ]
            }
        /* Selections */
        case .interface(_), .object(_), .union:
            switch field.type.inverted {
            case .nullable:
                /*
                 When decoding a nullable field we simply pass it down to the decoder.
                 */
                return ["return try selection.decode(data: data.\(name)[field.alias!])"]
            default:
                /*
                 When decoding a non-nullable field, we want to make sure that field is present.
                 */
                return [
                    "if let data = data.\(name)[field.alias!] {",
                    "    return try selection.decode(data: data)",
                    "}",
                    "throw SG.HttpError.badpayload",
                ]
            }
        }
    }

    // MARK: - Mocking

    /// Generates value placeholders for the API.
    private func generateMockData(for ref: GraphQL.OutputTypeRef) throws -> String {
        switch ref.namedType {
        /* Scalars */
        case let .scalar(scalar):
            let type = try options.scalar(scalar)
            return generateMockWrapper("\(type).mockValue", for: ref)
        /* Enumerations */
        case let .enum(enm):
            return generateMockWrapper("Enums.\(enm.pascalCase).allCases.first!", for: ref)
        /* Selections */
        case .interface(_), .object(_), .union:
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
        case .named:
            return value
        case .list:
            return "[]"
        case .nullable:
            return "nil"
        }
    }
}
