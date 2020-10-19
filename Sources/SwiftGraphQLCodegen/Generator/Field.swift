import Foundation

extension GraphQLCodegen {
    static func generateField(_ field: GraphQL.Field) -> String {
        """
        \(generateFieldDoc(for: field))
        \(generateFieldDeprecationDoc(for: field))
        func \(generateFnDefinition(for: field)) -> \(generateReturnType(for: field.type)) {
            /* Selection */
            let field = \(generateFieldLeaf(for: field))
            self.select(field)

            /* Decoder */
            if let data = self.response {
                return \(generateDecoder(for: field))
            }
            return \(generateMockData(for: field.type))
        }
    """
    }
    
    // MARK: - Documentation
    
    private static func generateFieldDoc(for field: GraphQL.Field) -> String {
        "/// \(field.description ?? field.name)"
    }
    
    private static func generateFieldDeprecationDoc(for field: GraphQL.Field) -> String {
        field.isDeprecated ? "@available(*, deprecated, message: \"\(field.deprecationReason ?? "")\")" : ""
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
            return "\(field.name)()"
        case .inputObject(_), .interface(_), .object(_), .union(_):
            let typeLock = generateObjectTypeLock(for: field.type.namedType.name)
            let decoderType = generateDecoderType(typeLock, for: field.type)
            return "\(field.name)<Type>(_ selection: Selection<Type, \(decoderType)>)"
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
    private static func generateFieldLeaf(for field: GraphQL.Field) -> String {
        switch field.type.namedType {
        case .scalar(_), .enumeration(_):
            return "GraphQLField.leaf(name: \"\(field.name)\")"
        case .inputObject(_), .interface(_), .object(_), .union(_):
            return "GraphQLField.composite(name: \"\(field.name)\", selection: selection.selection)"
        }
    }
    
    // MARK: - Decoders

    /// Generates a field decoder.
    private static func generateDecoder(for field: GraphQL.Field) -> String {
        switch field.type.namedType {
        case .scalar(_):
            let returnType = generateReturnType(for: field.type)
            return "(data as! [String: Any])[field.name] as! \(returnType)"
        case .enumeration(let enm):
            let decoderType = generateDecoderType("String", for: field.type)
            if decoderType == "String" {
                return "\(enm).init(rawValue: (data as! [String: Any])[field.name] as! String)!"
            }
            return "((data as! [String: Any])[field.name] as! \(decoderType)).map { \(enm).init(rawValue: $0)! }"
        case .inputObject(_), .interface(_), .object(_), .union(_):
            let decoderType = generateDecoderType("Any", for: field.type)
            return "selection.decode(data: ((data as! [String: Any])[field.name] as! \(decoderType)))"
        }
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
    
    private static func generateMockWrapper(_ value: String, for type: GraphQL.TypeRef) -> String {
        switch type {
        case .named(_):
            return "nil"
        case .list(let subRef):
            return "[]"
        case .nonNull(let subRef):
            return value
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
