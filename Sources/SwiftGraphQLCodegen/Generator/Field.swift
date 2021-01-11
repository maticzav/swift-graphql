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
        case .scalar(_), .enum(_):
            let arguments = try generateFnParameters(for: field.args)
            return "\(fnName)(\(arguments))"
        /* Selections */
        case .object(let typeLock):
            let type = "Objects.\(typeLock.pascalCase)"
            let decoderType = generateDecoderType(type, for: field.type)
            return try generateFnDefinitionWithSelection(
                name: fnName,
                args: field.args,
                decoderType: decoderType
            )
        case .interface(let typeLock):
            let typeLock = "Interfaces.\(typeLock.pascalCase)"
            let decoderType = generateDecoderType(typeLock, for: field.type)
            return try generateFnDefinitionWithSelection(
                name: fnName,
                args: field.args,
                decoderType: decoderType
            )
        case .union(let typeLock):
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
        case .nullable(_):
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
        case .scalar(let scalar):
            let scalar = try options.scalar(scalar)
            return generateDecoderType(scalar, for: ref)
        case .enum(let enm):
            let type = "Enums.\(enm.pascalCase)"
            return generateDecoderType(type, for: ref)
        case .interface(_),
            .object(_),
            .union(_):
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
                  "    arguments: ["
                ] + generateSelectionArguments(for: field.args).indent(by: 8) +
                [ "    ]",
                  ")"
                ]
        case .interface(_), .object(_), .union(_):
            return
                [ "let field = GraphQLField.composite(",
                  "    name: \"\(field.name)\",",
                  "    arguments: ["
                ] + generateSelectionArguments(for: field.args).indent(by: 8) +
                [ "    ],",
                  "    selection: selection.selection",
                  ")"
                ]
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
        case .named(let named):
            switch named {
            case .enum(let name), .inputObject(let name), .scalar(let name):
                return name
            }
        /* Wrappers */
        case .list(let subref):
            return "[\(generateArgumentType(for: subref))]"
        case .nonNull(let subref):
            return "\(generateArgumentType(for: subref))!"
        }
    }
    
    // MARK: - Accessors

    /// Generates a field decoder.
    private func generateDecoder(for field: GraphQL.Field) -> [String] {
        let name = field.name.camelCase
        
        switch field.type.inverted.namedType {
        /* Scalar, Enumeration */
        case .scalar(_), .enum(_):
            switch field.type.inverted {
            case .nullable(_):
                /*
                 When decoding a nullable scalar, we just return the value.
                 */
                return [ "return data.\(name)[field.alias!]" ]
            default:
                /*
                 In list value and non-optional scalars we want to make sure that value is present.
                 */
                return [
                    "if let data = data.\(name)[field.alias!] {",
                    "    return data",
                    "}",
                    "throw SG.HttpError.badpayload"
                ]
            }
        /* Selections */
        case .interface(_), .object(_), .union(_):
            switch field.type.inverted {
            case .nullable(_):
                /*
                 When decoding a nullable field we simply pass it down to the decoder.
                 */
                return [ "return try selection.decode(data: data.\(name)[field.alias!])" ]
            default:
                /*
                 When decoding a non-nullable field, we want to make sure that field is present.
                 */
                return [
                    "if let data = data.\(name)[field.alias!] {",
                    "    return try selection.decode(data: data)",
                    "}",
                    "throw SG.HttpError.badpayload"
                ]
            }
        }
    }
    
    // MARK: - Mocking

    /// Generates value placeholders for the API.
    private func generateMockData(for ref: GraphQL.OutputTypeRef) throws -> String {
        switch ref.namedType {
        /* Scalars */
        case .scalar(let scalar):
            let type = try options.scalar(scalar)
            return generateMockWrapper("\(type).mockValue", for: ref)
        /* Enumerations */
        case .enum(let enm):
            return generateMockWrapper("Enums.\(enm.pascalCase).allCases.first!", for: ref)
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
