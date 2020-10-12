import Foundation
//import SwiftFormat
//import SwiftFormatConfiguration


public struct GraphQLCodegen {
    /// Generates a target GraphQL Swift file.
    ///
    public static func generate(
        _ target: URL,
        from schemaURL: URL,
        onComplete: @escaping () -> Void = {}
    ) -> Void {
        /* Code generator function. */
        func generator(schema: GraphQL.Schema) -> Void {
            let code = self.generate(from: schema)
            
            /* Write the code to the file system. */
            let targetDir = target.deletingLastPathComponent()
            try! FileManager.default.createDirectory(
                at: targetDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            try! code.write(to: target, atomically: true, encoding: .utf8)
            
            onComplete()
        }
        
        /* Download the schema from endpoint. */
        GraphQLSchema.downloadFrom(schemaURL, handler: generator)
    }
    
    /// Generates the API and returns it to handler.
    public static func generate(from schemaURL: URL, handler: @escaping (String) -> Void) -> Void {
        /* Code generator function. */
        func generator(schema: GraphQL.Schema) -> Void {
            let code = self.generate(from: schema)
            handler(code)
        }
        
        /* Download the schema from endpoint. */
        GraphQLSchema.downloadFrom(schemaURL, handler: generator)
    }
    
    
    /* Internals */
    
    
    /// Generates the code that can be used to define selections.
    private static func generate(from schema: GraphQL.Schema) -> String {
        /* Data */
        
        let operations: [(name: String, type: GraphQL.FullType)] = [
            ("RootQuery", schema.queryType.name),
            ("RootMutation",schema.mutationType?.name),
            ("RootSubscription",schema.subscriptionType?.name)
        ].compactMap { (name, operation) in
            schema.types.first(where: { $0.name == operation }).map { (name, $0) }
        }
        
        let objects: [(name: String, type: GraphQL.FullType)] = schema.objects.map {
            (name: generateObjectType(for: $0.name), type: $0)
        }
        
        /* Generate the API. */
        let code = """
            import SwiftGraphQL

            // MARK: - Operations
            
            \(operations.map { generateObject($0.name, for: $0.type) }.lines)

            // MARK: - Objects

            \(generatePhantomTypes(for: schema.objects))

            // MARK: - Selection

            \(objects.map { generateObject($0.name, for: $0.type) }.lines)

            // MARK: - Enums

            \(schema.enums.map { generateEnum($0) }.lines)
            """
        
        return code
        
//        /* Format the code. */
//        var parsed: String = ""
//
//        let configuration = Configuration()
//        let formatted = SwiftFormatter(configuration: configuration)
//
//        try! formatted.format(source: code, assumingFileURL: nil, to: &parsed)
//
//        /* Return */
//
//        return parsed
    }
    

    /* Objects */
    
    /// Generates an object phantom type entry.
    private static func generatePhantomTypes(for types: [GraphQL.FullType]) -> String {
        """
        enum Object {
        \(types.map { generatePhantomType(for: $0) }.lines)
        }
        
        \(types.map { generatePhantomTypeAlias(for: $0)}.lines)
        """
    }
    
    private static func generatePhantomType(for type: GraphQL.FullType) -> String {
        """
            enum \(type.name) {}
        """
    }
    
    private static func generatePhantomTypeAlias(for type: GraphQL.FullType) -> String {
        """
            typealias \(type.name)Object = Object.\(type.name)
        """
    }
    
    /// Generates an object type used for aliasing a phantom type.
    private static func generateObjectType(for typeName: String) -> String {
        "\(typeName)Object"
    }

    /// Generates a function to handle a type.
    private static func generateObject(_ typeName: String, for type: GraphQL.FullType) -> String {
        // TODO: add support for all fields!
        let fields = (type.fields ?? []).filter {
            switch $0.type.namedType {
            case .scalar(_), .object(_), .enumeration(_):
                return true
            default:
                return false
            }
        }
        
        return """
        /* \(type.name) */

        extension SelectionSet where TypeLock == \(typeName) {
        \(fields.map(generateObjectField).lines)
        }
        """
    }

    private static func generateObjectField(_ field: GraphQL.Field) -> String {
        /* Code Parts */
        let description = "/// \(field.description ?? "")"
        let fnDefinition = generateFnDefinition(for: field)
        let returnType = generateReturnType(for: field.type)
        
        let fieldLeaf = generateFieldLeaf(for: field)
        let decoder = generateDecoder(for: field)
        let mockData = generateMockData(for: field.type)
        
        return """
            \(description)
            func \(fnDefinition) -> \(returnType) {
                let field = \(fieldLeaf)

                // selection
                self.select(field)

                // decoder
                if let data = self.data {
                   return \(decoder)
                }

                // mock placeholder
                return \(mockData)
            }
        """
    }
    
    /// Generates a function definition for a field.
    private static func generateFnDefinition(for field: GraphQL.Field) -> String {
        switch field.type {
        /* Named Type */
        case .named(let type):
            switch type {
            case .scalar(_), .enumeration(_):
                return "\(field.name)()"
            case .inputObject(_),
                 .interface(_),
                 .object(_),
                 .union(_):
                let typeLock = generateObjectType(for: field.type.namedType.name)
                return "\(field.name)<Type>(_ selection: SelectionSet<Type, \(typeLock)>)"
            }
        /* List Type */
        case .list(let subRef), .nonNull(let subRef):
            let subField = GraphQL.Field(
                name: field.name,
                description: field.description,
                args: field.args,
                type: subRef,
                isDeprecated: field.isDeprecated,
                deprecationReason: field.deprecationReason
            )
            return generateFnDefinition(for: subField)
        }
    }
    
    /// Recursively generates a return type of a referrable type.
    private static func generateReturnType(for ref: GraphQL.TypeRef) -> String {
        switch ref {
        /* Named Type */
        case .named(let type):
            switch type {
            case .scalar(let scalar):
                return generateReturnType(for: scalar)
            case .enumeration(let enm):
                return "\(enm)?"
            case .inputObject(_),
                 .interface(_),
                 .object(_),
                 .union(_):
                return "Type?"
            }
        /* Wrapped types */
        case .list(let subRef):
            return "[\(generateReturnType(for: subRef))]?"
        case .nonNull(let subRef):
            // everything is nullable by default, that's why
            // we are removing question mark
            var nullable = generateReturnType(for: subRef)
            nullable.remove(at: nullable.index(before: nullable.endIndex))
            return nullable
        }
    }
    
    /// Generates a return type of a named type.
    private static func generateReturnType(for namedType: GraphQL.NamedType) -> String {
        switch namedType {
        case .scalar(let scalar):
            return generateReturnType(for: scalar)
        case .enumeration(_),
             .inputObject(_),
             .interface(_),
             .object(_),
             .union(_):
            return "Type?"
        }
    }
    
    /// Translates a scalar abstraction into Swift-compatible type.
    ///
    /// - Note: Every type is optional by default since we are comming from GraphQL world.
    private static func generateReturnType(for scalar: GraphQL.Scalar) -> String {
        switch scalar {
        case .boolean:
            return "Bool?"
        case .float:
            return "Double?"
        case .integer:
            return "Int?"
        case .string, .id:
            return "String?"
        case .custom(let type):
            return "\(type)?"
        }
    }
    
    /// Generates an internal leaf definition used for composing selection set.
    private static func generateFieldLeaf(for field: GraphQL.Field) -> String {
        switch field.type.namedType {
        case .scalar(_), .enumeration(_):
            return "GraphQLField.leaf(name: \"\(field.name)\")"
        case .inputObject(_), .interface(_), .object(_), .union(_):
            return "GraphQLField.composite(name: \"\(field.name)\", selection: selection.selection)"
        }
        
    }
    
    /// Generates a field decoder.
    private static func generateDecoder(for field: GraphQL.Field) -> String {
        switch field.type.namedType {
        case .scalar(_):
            let returnType = generateReturnType(for: field.type)
            return "data[field.name] as! \(returnType)"
        case .enumeration(let enm):
            let decoderType = generateDecoderType("String", for: field.type)
            if decoderType == "String" {
                return "\(enm).init(rawValue: data[field.name] as! String)!"
            }
            return "(data[field.name] as! \(decoderType)).map { \(enm).init(rawValue: $0)! }"
        case .inputObject(_), .interface(_), .object(_), .union(_):
            let decoderType = generateDecoderType("Any", for: field.type)
            if decoderType == "Any" {
                return "selection.decode(data: (data[field.name] as! Any))"
            }
            return "(data[field.name] as! \(decoderType)).map { selection.decode(data: $0) }"
        }
        /**
         We might need `list` and `null` selection set since the above nesting may be arbitratily deep.
            People may use a nested nested list, for example, and schema allows for that. The problem lays in the
            current decoders.
         */
    }
    
    /// Generates an intermediate type used in custom decoders to cast JSON representation of the data.
    private static func generateDecoderType(_ typeName: String, for type: GraphQL.TypeRef) -> String {
        switch type {
        case .named(_):
            return "\(typeName)?"
        /* Wrapped types */
        case .list(let subRef):
            return "[\(generateDecoderType(typeName, for: subRef))]?"
        case .nonNull(let subRef):
            // everything is nullable by default, that's why
            // we are removing question mark
            var nullable = generateDecoderType(typeName, for: subRef)
            nullable.remove(at: nullable.index(before: nullable.endIndex))
            return nullable
        }
    }
    
    /// Generates value placeholders for the API.
    private static func generateMockData(for ref: GraphQL.TypeRef) -> String {
        switch ref {
        /* Named Types */
        case let .named(named):
            switch named {
            case .scalar(let scalar):
                return generateMockData(for: scalar)
            case .enumeration(let enm):
                return "\(enm).allCases.first!"
            default:
                return "selection.mock()"
            }
        /* Wrappers */
        case .list(_):
            return "[]"
        case .nonNull(let subRef):
            return generateMockData(for: subRef)
        }
    }
    
    /// Generates mock data for an abstract scalar type.
    private static func generateMockData(for scalar: GraphQL.Scalar) -> String {
        switch scalar {
        case .boolean:
            return "true"
        case .float:
            return "3.14"
        case .integer:
            return "42"
        case .string:
            return "\"Matic Zavadlal\""
        case .id:
            return "\"8378\""
        case .custom(_): // TODO!
            return ""
        }
    }
    
    /* Enums */

    /// Generates an enumeration code.
    private static func generateEnum(_ type: GraphQL.FullType) -> String {
        let cases = type.enumValues ?? []
        return """
        enum \(type.name): String, CaseIterable, Codable {
        \(cases.map(generateEnumCase).lines)
        }
        """
    }

    private static func generateEnumCase(_ env: GraphQL.EnumValue) -> String {
        """
            case \(env.name) = \"\(env.name)\"
        """
    }

}


