import Foundation
//import SwiftFormat
//import SwiftFormatConfiguration


public struct GraphQLCodegen {
    /// Generates a target GraphQL Swift file.
    public static func generate(_ target: URL, from schemaURL: URL) -> Void {
        /* Code generator function. */
        func generator(schema: GraphQL.Schema) -> Void {
            let code = self.generate(from: schema).data(using: .utf8)
            
            /* Write the code to the file system. */
            try! FileManager.default.createFile(
                atPath: target.absoluteString,
                contents: code,
                attributes: nil
            )
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
    
//    \(generateSelectionSet("RootQuery", for: schema.queryType))
//    \(generateSelectionSet("RootMutation", for: schema.queryType))
//    \(generateSelectionSet("RootSubscription", for: schema.queryType))
    
    /// Generates the code that can be used to define selections.
    static func generate(from schema: GraphQL.Schema) -> String {
        /* Generate the API. */
        let code = """
            import SwiftGraphQL

            // MARK: - Operations
            
            

            // MARK: - Objects

            enum Object {
            \(schema.objects.map(generateObjectEnum).lines)
            }

            // MARK: - Selection

            \(schema.objects.map { generateObject($0.name, for: $0) }.lines)


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
    static func generateObjectEnum(_ type: GraphQL.FullType) -> String {
        "enum \(type.name) {}"
    }

    /// Generates a function to handle a type.
    static func generateObject(_ typeName: String, for type: GraphQL.FullType) -> String {
        let fields = type.fields ?? []
        return """
        /* \(type.name) */

        typealias \(typeName) = Object.\(type.name)

        extension SelectionSet where TypeLock == \(typeName) {
        /* Fields */
        \(fields.map(generateObjectField).lines)
        }
        """
    }

    static func generateObjectField(_ field: GraphQL.Field) -> String {
        let returnType = generateReturnType(for: field.type)
        let mockData = generateMockData(for: field.type)
        
        /* Common */
        
        let description = "/// \(field.description ?? "")"
        let fnType = "func \(field.name)() -> \(returnType)"
        
        
        return """
        /// \(description)
        \(fnType) {
            let field = GraphQLField.leaf(name: "\(field.name)")

            if let data = self.data {
               return data[field.name] as! \(returnType)
            }

            return \(mockData)
        }
        """
    }
    
    /// Recursively generates a return type of a referrable type.
    static func generateReturnType(for ref: GraphQL.TypeRef) -> String {
        switch ref {
        /* Custom type */
        case .named(let type):
            switch type {
            case .scalar(let scalar):
                return generateReturnType(for: scalar)
            case .enumeration(let name),
                 .inputObject(let name),
                 .interface(let name),
                 .object(let name),
                 .union(let name):
                return "\(name)?" // everything is nullable by default
            }
        /* Wrapped types */
        case .list(let subRef):
            return "[\(generateReturnType(for: subRef))]"
        case .nonNull(let subRef):
            var nullable = generateReturnType(for: subRef)
            nullable.remove(at: nullable.index(before: nullable.endIndex))
            return nullable
        }
    }
    
    /// Translates a scalar abstraction into Swift-compatible type.
    ///
    /// - Note: Every type is optional by default since we are comming from GraphQL world.
    static func generateReturnType(for scalar: GraphQL.Scalar) -> String {
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
    
    /// Generates value placeholders for the API.
    static func generateMockData(for ref: GraphQL.TypeRef) -> String {
        switch ref {
        /* Named Types */
        case let .named(named):
            switch named {
            case .scalar(let scalar):
                return generateMockData(for: scalar)
            default:
                return ""
            }
        /* Wrappers */
        case .list(_):
            return "[]"
        case .nonNull(_):
            return ""
        }
    }
    
    /// Generates mock data for an abstract scalar type.
    static func generateMockData(for scalar: GraphQL.Scalar) -> String {
        switch scalar {
        case .boolean:
            return "true"
        case .float:
            return "3.14"
        case .integer:
            return "42"
        case .string:
            return "Matic Zavadlal"
        case .id:
            return "92"
        case .custom(_): // TODO!
            return ""
        }
    }
    
    /* Enums */

    /// Generates an enumeration code.
    static func generateEnum(_ type: GraphQL.FullType) -> String {
        let cases = type.enumValues ?? []
        return """
        enum \(type.name): String, CaseIterable, Codable {
        \(cases.map(generateEnumCase).lines)
        }
        """
    }

    static func generateEnumCase(_ env: GraphQL.EnumValue) -> String {
        "case \(env.name) = \"\(env.name)\""
    }

}


