import Foundation

extension GraphQLCodegen {
    /// Generates a SwiftGraphQL field.
    static func generateField(_ field: GraphQL.Field) -> String {
        (
            [ generateFieldDoc(for: field)
            , generateFieldDeprecationDoc(for: field)
            , "func \(generateFnDefinition(for: field)) -> \(generateReturnType(for: field.type)) {"
            , "    /* Selection */"
            ] +
            generateFieldSelection(for: field).map { "    \($0)" } +
            [ "    self.select(field)"
            , ""
            , "    /* Decoder */"
            , "    if let data = self.response as? [String: Any] {"
            , "        return \(generateDecoder(for: field))"
            , "    }"
            , "    return \(generateMockData(for: field.type))"
            , "}"
            ]
        )
        .compactMap { $0 }
        .map { "    \($0)"}
        .joined(separator: "\n")
    }
    
    // MARK: - Documentation
    
    /// Generates field documentation.
    private static func generateFieldDoc(for field: GraphQL.Field) -> String? {
        field.description.map { "/// \($0)" }
    }
    
    /// Generates deprecation documentation.
    private static func generateFieldDeprecationDoc(for field: GraphQL.Field) -> String? {
        field.isDeprecated ? "@available(*, deprecated, message: \"\(field.deprecationReason ?? "")\")" : nil
    }
    
    // MARK: - Function definition

    /// Generates a function definition for a field.
    private static func generateFnDefinition(for field: GraphQL.Field) -> String {
        /**
         Cases:
             1.
         */
        switch field.type.namedType {
        case .scalar(_), .enumeration(_):
            return "\(field.name.camelCase)(\(generateFnArguments(for: field)))"
        case .inputObject(_), .interface(_), .object(_), .union(_):
            let typeLock = generateObjectTypeLock(for: field.type.namedType.name.pascalCase)
            let decoderType = generateDecoderType(typeLock, for: field.type)
            // Generate based on arguments.
            if field.args.isEmpty {
                return "\(field.name.camelCase)<Type>(_ selection: Selection<Type, \(decoderType)>)"
            }
            return "\(field.name.camelCase)<Type>(\(generateFnArguments(for: field)), _ selection: Selection<Type, \(decoderType)>)"
        }
    }
    
    /// Generates arguments for accessor function.
    private static func generateFnArguments(for field: GraphQL.Field) -> String {
        field.args.map { generateArgumentParameter(for: $0) }.joined(separator: ", ")
    }
    
    /// Generates a function parameter based on an input value.
    private static func generateArgumentParameter(for input: GraphQL.InputValue) -> String {
        if let defaultValue = input.defaultValue {
            return "\(input.name.camelCase): \(generateArgumentParameterType(for: input.type)) = \(generateArgumentDefaultValue(defaultValue, for: input.type))"
        }
        return "\(input.name.camelCase): \(generateArgumentParameterType(for: input.type))"
    }
    
    /// Generates a type definition for an argument function parameter.
    private static func generateArgumentParameterType(for ref: GraphQL.TypeRef) -> String {
        generateArgumentParameterType(for: ref.inverted)
    }
    
    /// Generates a type definition for an argument function parameter.
    private static func generateArgumentParameterType(for ref: GraphQL.InvertedTypeRef) -> String {
        switch ref {
        case .named(let named):
            switch named {
            case .scalar(let scalar):
                return generateReturnType(for: scalar)
            case .enumeration(_):
                return named.name.pascalCase
            default:
                return "" // TODO
            }
        case .list(let subref):
            return "[\(generateArgumentParameterType(for: subref))]"
        case .nullable(let subref):
            return "\(generateArgumentParameterType(for: subref))?"
        }
    }
    
    /// Prints a formatted default value for input parameter.
    private static func generateArgumentDefaultValue(_ value: String, for ref: GraphQL.TypeRef) -> String {
        generateArgumentDefaultValue(value, for: ref.inverted)
    }
    
    /// Prints a formatted default value for input parameter.
    private static func generateArgumentDefaultValue(_ value: String, for ref: GraphQL.InvertedTypeRef) -> String {
        switch ref {
        case .named(let named):
            switch named {
            case .scalar(let scalar):
                switch scalar {
                case .string:
                    return "\"\(value)\""
                default:
                    return value
                }
            case .enumeration(let enm):
                return "\(named.name.pascalCase).init(string: \"\(enm)\")!"
            default:
                return "" // TODO
            }
        case .list(let subref):
            return "[\(generateArgumentDefaultValue(value, for: subref))]"
        case .nullable(_):
            return "" // TODO
        }
    }
    
    // MARK: - Return types

    /// Recursively generates a return type of a referrable type.
    private static func generateReturnType(for ref: GraphQL.TypeRef) -> String {
        switch ref.namedType {
        case .scalar(let scalar):
            let scalarType = generateReturnType(for: scalar)
            return generateDecoderType(scalarType, for: ref)
        case .enumeration(let enm):
            return generateDecoderType(enm, for: ref)
        case .inputObject(_),
            .interface(_),
            .object(_),
            .union(_):
            return "Type"
        }
    }


    /// Translates a scalar abstraction into Swift-compatible type.
    ///
    /// - Note: Every type is optional by default since we are comming from GraphQL world.
    private static func generateReturnType(for scalar: GraphQL.Scalar) -> String {
        // TODO: Generate custom ID types.
        switch scalar {
        case .boolean:
            return "Bool"
        case .float:
            return "Double"
        case .integer:
            return "Int"
        case .string, .id:
            return "String"
        case .custom(let type):
            return "\(type)"
        }
    }
    
    // MARK: - Selection

    /// Generates an internal leaf definition used for composing selection set.
    private static func generateFieldSelection(for field: GraphQL.Field) -> [String] {
        switch field.type.namedType {
        case .scalar(_), .enumeration(_):
            return
                [ "let field = GraphQLField.leaf("
                , "    name: \"\(field.name)\","
                , "    arguments: ["
                , generateSelectionArguments(for: field).map { "        \($0)" }.joined(separator: "\n")
                , "    ]"
                , ")"
                ]
        case .inputObject(_), .interface(_), .object(_), .union(_):
            return
                [ "let field = GraphQLField.composite("
                , "    name: \"\(field.name)\","
                , "    arguments: ["
                , generateSelectionArguments(for: field).map { "        \($0)" }.joined(separator: "\n")
                , "    ],"
                , "    selection: selection.selection"
                , ")"
                ]
        }
    }
    
    /// Generates a dictionary of argument builders.
    private static func generateSelectionArguments(for field: GraphQL.Field) -> [String] {
        field.args
            .map { #"Argument(name: "\#($0.name)", value: \#(generateArgumentEncoder($0.name, for: $0.type))),"# }
    }
    
    /// Generates a function that will encode the argument.
    private static func generateArgumentEncoder(_ paramName: String, for ref: GraphQL.TypeRef) -> String {
        generateArgumentEncoder(paramName, for: ref.inverted)
    }
    
    /// Generates a function that will encode the argument.
    private static func generateArgumentEncoder(_ paramName: String, for ref: GraphQL.InvertedTypeRef) -> String {
        switch ref {
        case .named(let named):
            switch named {
            case .scalar(let scalar):
                return generateScalarArgumentEncoder(paramName, for: scalar)
            default:
                return "" // TODO
            }
        case .list(let subref):
            return "Value.list(\(paramName)) { \(generateArgumentEncoder("$0", for: subref)) }"
        case .nullable(let subref):
            return "\(paramName).map { \(generateArgumentEncoder("$0", for: subref)) }"
        }
    }
    
    /// Generates an encoder for scalar type.
    private static func generateScalarArgumentEncoder(_ paramName: String, for scalar: GraphQL.Scalar) -> String {
        switch scalar {
        case .boolean:
            return "Value.boolean(\(paramName))"
        case .float:
            return "Value.float(\(paramName))"
        case .integer:
            return "Value.int(\(paramName))"
        case .string, .id:
            return "Value.string(\(paramName))"
        case .custom(_):
            return "" // TODO: Custom input scalars?
        }
    }
    
    // MARK: - Decoders

    /// Generates a field decoder.
    private static func generateDecoder(for field: GraphQL.Field) -> String {
        switch field.type.namedType {
        /* Scalar */
        case .scalar(_):
            let returnType = generateReturnType(for: field.type)
            return "data[field.name] as! \(returnType)"
        /* Enumeartion */
        case .enumeration(let enm):
            switch field.type.inverted {
            case .named(_):
                return "\(enm).init(rawValue: data[field.name] as! String)!"
            case .list(let subRef), .nullable(let subRef):
                let decoderType = generateDecoderType("String", for: field.type)
                let decoderMapping = generateDecoderMapping("\(enm).init(rawValue: $0)!", for: subRef)
                return "(data[field.name] as! \(decoderType)).map { \(decoderMapping) }"
            }
        /* Selections */
        case .inputObject(_), .interface(_), .object(_), .union(_):
            let decoderType = generateDecoderType("Any", for: field.type)
            switch field.type.inverted {
            case .nullable(_):
                return "(data[field.name] as! \(decoderType)).map { selection.decode(data: $0) } ?? selection.mock()"
            default:
                return "selection.decode(data: (data[field.name] as! \(decoderType)))"
            }
            
        }
    }
    
    /// Generates consecutive nested `.map` functions based on referable type nesting.
    private static func generateDecoderMapping(_ decoder: String, for ref: GraphQL.InvertedTypeRef) -> String {
        switch ref {
        case .named(_):
            return decoder
        case .list(let subRef), .nullable(let subRef):
            return "$0.map { \(generateDecoderMapping(decoder, for: subRef)) }"
        }
    }
    
    /// Generates an intermediate type used in custom decoders to cast JSON representation of the data.
    private static func generateDecoderType(_ typeName: String, for ref: GraphQL.TypeRef) -> String {
        generateDecoderType(typeName, for: ref.inverted)
    }

    /// Generates an intermediate type used in custom decoders to cast JSON representation of the data.
    private static func generateDecoderType(_ typeName: String, for ref: GraphQL.InvertedTypeRef) -> String {
        switch ref {
        case .named(_):
            return typeName
        case .list(let subRef):
            return "[\(generateDecoderType(typeName, for: subRef))]"
        case .nullable(let subRef):
            return "\(generateDecoderType(typeName, for: subRef))?"
        }
    }
    
    // MARK: - Mocking

    /// Generates value placeholders for the API.
    private static func generateMockData(for ref: GraphQL.TypeRef) -> String {
        switch ref.namedType {
        case .scalar(let scalar):
            let value = generateMockData(for: scalar)
            return generateMockWrapper(value, for: ref)
        case .enumeration(let enm):
            let value = "\(enm).allCases.first!"
            return generateMockWrapper(value, for: ref)
        case .inputObject(_), .interface(_), .object(_), .union(_):
            return "selection.mock()"
        }
    }
    
    /// Generates the mock value for wrapped type.
    private static func generateMockWrapper(_ value: String, for ref: GraphQL.TypeRef) -> String {
        generateMockWrapper(value, for: ref.inverted)
    }
    
    /// Generates the mock value for wrapped type.
    private static func generateMockWrapper(_ value: String, for ref: GraphQL.InvertedTypeRef) -> String {
        switch ref {
        case .named(_):
            return value
        case .list(_):
            return "[]"
        case .nullable(_):
            return "nil"
        }
    }

    /// Generates mock data for an abstract scalar type.
    private static func generateMockData(for scalar: GraphQL.Scalar) -> String {
        switch scalar {
        case .id:
            return "\"8378\""
        case .boolean:
            return "true"
        case .float:
            return "3.14"
        case .integer:
            return "42"
        case .string:
            return "\"Matic Zavadlal\""
        case .custom(_): // TODO!
            return ""
        }
    }
}
