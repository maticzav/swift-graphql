//
//  File.swift
//  
//
//  Created by Matic Zavadlal on 10/10/2020.
//

import Foundation

// MARK: - GraphQL AST

// MARK: - Generated

/*
 1. In general it is always so that you should create phantom types for every object, union... - generally anything
     that has some form of a selection set - and extend the selection set afterwards.
 2. The return type of every selector is a generic "Type". We modify the return type in case it is nullable or list.
 */

/* Generate the schema and save it to the filesystem. */

public struct GraphQLCodegen {
    /// Generates a target GraphQL Swift file.
    public static func generate(_ target: URL, from schemaURL: URL) -> Void {
        /* Code generator function. */
        func generator(schema: GraphQL.Schema) -> Void {
            let code = self.generate(from: schema)
            
            /* Write the code to the file system. */
            try! code.write(to: target, atomically: false, encoding: .utf8)
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
        """
        import SwiftGraphQL

        // MARK: - Operations
        
        

        // MARK: - Objects

        enum Object {
            \(schema.types.map(generateObjectEnum).lines)
        }

        // MARK: - Selection

        \(schema.types.map { generateSelectionSet($0.name, for: $0) }.lines)

        """
    }
    
    
    static func generateObjectEnum(_ type: GraphQL.FullType) -> String {
        "enum \(type.name) {}"
    }


    /* SelectionSet */

    // TODO:

    /// Generates a function to handle a type.
    static func generateSelectionSet(_ typeName: String, for type: GraphQL.FullType) -> String {
        """
        typealias \(typeName) = Object.\(type.name)

        extension SelectionSet where TypeLock == \(typeName) {
            /* Fields */
        }
        """
    }


    /// Generates a function to handle a type.
    static func generateObject(_ typeName: String, for type: GraphQL.FullType) -> String {
        let fields = type.fields ?? []
        return """
        typealias \(typeName) = Object.\(type.name)

        extension SelectionSet where TypeLock == \(typeName) {
            /* Fields */
            \(fields.map(generateObjectField).lines)
        }
        """
    }

    static func generateObjectField(_ field: GraphQL.Field) -> String {
        let returnType = "String"
        let mockData = ""
        
        return """
        /// \(field.description ?? "\(field.name) selection.")
        func \(field.name)() -> \(returnType) {
            let field = GraphQLField.leaf(name: "\(field.name)")

            if let data = self.data {
               return data[field.name] as! \(returnType)
            }

            return \(mockData)
        }
        """
    }

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


