//
//  File.swift
//  
//
//  Created by Matic Zavadlal on 10/10/2020.
//

import Foundation
import GraphQL

// MARK: - GraphQL AST

public enum GraphQL {
    public struct Schema: Codable {
        let description: String?
        let types: [SchemaType]
        let queryType: SchemaType
        let mutationType: SchemaType
        let subscriptionType: SchemaType
    }
    
    public struct SchemaType: Codable {
        let kind: TypeKind
        let name: String
        let description: String?
        let fields: [Field]
        let enumValues: [EnumValue]
        
        public enum TypeKind: String, Codable {
            case scalar = "SCALAR"
            case object = "OBJECT"
            case interface = "INTERFACE"
            case union  = "UNION"
            case enumeration = "ENUM"
            case inputObject = "INPUT_OBJECT"
            case list = "LIST"
            case nonNull = "NON_NULL"
        }
        
        public struct Field: Codable {
            let name: String
            let description: String?
            let args: [InputValue]
            let type: SchemaType
            let isDeprecated: Bool
            let deprecationReason: String?
        }
        
        public struct InputValue: Codable {
            let name: String
            let description: String?
            let type: SchemaType
            let defaultValue: String?
        }
        
        public struct EnumValue: Codable {
            let name: String
            let description: String?
            let isDeprecated: Bool
            let deprecationReason: String?
        }
    }
}


// MARK: - Generated

/*
 1. In general it is always so that you should create phantom types for every object, union... - generally anything
     that has some form of a selection set - and extend the selection set afterwards.
 2. The return type of every selector is a generic "Type". We modify the return type in case it is nullable or list.
 */

/* Generate the schema and save it to the filesystem. */

/// Generates the code that can be used to define selections.
public func generate(from schemaPath: URL) -> String {
    let source = try! String(contentsOf: schemaPath, encoding: .utf8)
    let schema = parse(source.data(using: .utf8)!)
    return generate(from: schema)
}

func parse(_ data: Data) -> GraphQL.Schema {
    let decoder = JSONDecoder()
    let schema = try! decoder.decode(GraphQL.Schema.self, from: data)
    
    return schema
}

/// Generates the code that can be used to define selections.
public func generate(from schema: GraphQL.Schema) -> String {
    """
    import SwiftGraphQL

    // MARK: - Operations
    
    \(generateSelectionSet("RootQuery", for: schema.queryType))

    \(generateSelectionSet("RootMutation", for: schema.queryType))

    \(generateSelectionSet("RootSubscription", for: schema.queryType))

    // MARK: - Objects

    enum Object {
        \(schema.objects.map(generateObjectEnum).lines)
    }

    // MARK: - Selection

    \(schema.objects.map { generateSelectionSet($0.name, for: $0) }.lines)

    
    """
        .formatted
}

func generateObjectEnum(_ type: GraphQL.SchemaType) -> String {
    "enum \(type.name) {}"
}


/* SelectionSet */

// TODO:

/// Generates a function to handle a type.
func generateSelectionSet(_ typeName: String, for type: GraphQL.SchemaType) -> String {
    """
    typealias \(typeName) = Object.\(type.name)

    extension SelectionSet where TypeLock == \(typeName) {
        /* Fields */
        \(type.fields.map(generateSelectionSetField))
    }
    """
}


/// Generates a function to handle a type.
func generateObject(_ typeName: String, for type: GraphQL.SchemaType) -> String {
    """
    typealias \(typeName) = Object.\(type.name)

    extension SelectionSet where TypeLock == \(typeName) {
        /* Fields */
        \(type.fields.map(generateObjectField))
    }
    """
}

func generateObjectField(_ field: GraphQL.SchemaType.Field) -> String {
    let returnType = "String"
    let mockData = ""
    
    return """
    /// \(field.description)
    func \(field.name)() -> \(returnType) {
        let field = GraphQLField.leaf(name: "\(field.name)")

        if let data = self.data {
           return data[field.name] as! \(returnType)
        }

        return \(mockData)
    }
    """
}

func generateEnum(_ type: GraphQL.SchemaType) -> String {
    """
    enum \(type.name): String, CaseIterable, Codable {
        \()
    }
    """
}

func generateEnumCase(_ env: GraphQL.SchemaType.EnumValue) -> String {
    "case \(env.name)"
}
