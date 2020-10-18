import XCTest
@testable import SwiftGraphQLCodegen


final class SchemaTests: XCTestCase {
    /* Schema */
    
    func testDecodeSchema() {
        let json = """
        {
          "data": {
            "__schema": {
              "queryType": {
                "name": "Query"
              },
              "mutationType": null,
              "subscriptionType": null,
              "types": [
                {
                  "kind": "OBJECT",
                  "name": "Human",
                  "description": "A humanoid creature in the Star Wars universe.",
                  "fields": [
                    {
                      "name": "name",
                      "description": "The name of the character",
                      "args": [],
                      "type": {
                        "kind": "SCALAR",
                        "name": "String",
                        "ofType": null
                      },
                      "isDeprecated": false,
                      "deprecationReason": null
                    }
                  ],
                  "inputFields": null,
                  "interfaces": [
                    {
                      "kind": "INTERFACE",
                      "name": "Character",
                      "ofType": null
                    }
                  ],
                  "enumValues": null,
                  "possibleTypes": null
                }
              ]
            }
          }
        }
        """
        
        /* Decode */
        
        let value = GraphQL.parse(json.data(using: .utf8)!)
        let expected = GraphQL.Schema(
            types: [
                GraphQL.FullType(
                    kind: GraphQL.TypeKind.object,
                    name: "Human",
                    description: "A humanoid creature in the Star Wars universe.",
                    fields: [
                        GraphQL.Field(
                            name: "name",
                            description: "The name of the character",
                            args: [],
                            type: .named(.scalar(.string)),
                            isDeprecated: false,
                            deprecationReason: nil
                        )
                    ],
                    inputFields: nil,
                    interfaces: [
                        .named(.interface("Character"))
                    ],
                    enumValues: nil,
                    possibleTypes: nil
                ),
            ],
            queryType: GraphQL.Operation(name: "Query"),
            mutationType: nil,
            subscriptionType: nil
        )
        
        /* Tests */
        
        XCTAssertEqual(value, expected)
    }
    
    func testSchemaObjects() {
        let schema = GraphQL.Schema(
            types: [
                GraphQL.FullType(
                    kind: GraphQL.TypeKind.object,
                    name: "Object",
                    description: nil,
                    fields: nil,
                    inputFields: nil,
                    interfaces: nil,
                    enumValues: nil,
                    possibleTypes: nil
                ),
                GraphQL.FullType(
                    kind: GraphQL.TypeKind.object,
                    name: "__Object",
                    description: nil,
                    fields: nil,
                    inputFields: nil,
                    interfaces: nil,
                    enumValues: nil,
                    possibleTypes: nil
                ),
                GraphQL.FullType(
                    kind: GraphQL.TypeKind.enumeration,
                    name: "Enum",
                    description: nil,
                    fields: nil,
                    inputFields: nil,
                    interfaces: nil,
                    enumValues: nil,
                    possibleTypes: nil
                ),
            ],
            queryType: GraphQL.Operation(name: "RootQuery"),
            mutationType: nil,
            subscriptionType: nil
        )
        
        /* Tests */
        
        XCTAssertEqual(
            schema.objects.map { $0.name },
            ["Object"]
        )
    }

    
    func testSchemaEnums() {
        let schema = GraphQL.Schema(
            types: [
                GraphQL.FullType(
                    kind: GraphQL.TypeKind.enumeration,
                    name: "Enum",
                    description: nil,
                    fields: nil,
                    inputFields: nil,
                    interfaces: nil,
                    enumValues: nil,
                    possibleTypes: nil
                ),
                GraphQL.FullType(
                    kind: GraphQL.TypeKind.enumeration,
                    name: "__Enum",
                    description: nil,
                    fields: nil,
                    inputFields: nil,
                    interfaces: nil,
                    enumValues: nil,
                    possibleTypes: nil
                ),
                GraphQL.FullType(
                    kind: GraphQL.TypeKind.object,
                    name: "Object",
                    description: nil,
                    fields: nil,
                    inputFields: nil,
                    interfaces: nil,
                    enumValues: nil,
                    possibleTypes: nil
                ),
            ],
            queryType: GraphQL.Operation(name: "RootQuery"),
            mutationType: nil,
            subscriptionType: nil
        )
        
        /* Tests */
        
        XCTAssertEqual(
            schema.enums.map { $0.name },
            ["Enum"]
        )
    }
    
    func testSchemaOperations() {
        let schema = GraphQL.Schema(
            types: [],
            queryType: GraphQL.Operation(name: "RootQuery"),
            mutationType: GraphQL.Operation(name: "RootMutation"),
            subscriptionType: nil
        )
        
        /* Tests */
        
        XCTAssertEqual(schema.operations, ["RootQuery", "RootMutation"])
    }
    
    /* Field */
    
    func testDecodeField() {
        /* Data */
        let data = """
        {
            "name": "hero",
            "description": "The character",
            "args": [
                {
                  "name": "id",
                  "description": null,
                  "type": {
                      "kind": "SCALAR",
                      "name": "ID",
                      "ofType": null
                  },
                  "defaultValue": null
                }
            ],
            "type": {
                "kind": "SCALAR",
                "name": "String",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        }
        """.data(using: .utf8)!
        
        /* Decoder */
        
        let value = try! JSONDecoder().decode(GraphQL.Field.self, from: data)
        
        /* Tests */
        
        let expected = GraphQL.Field(
            name: "hero",
            description: "The character",
            args: [GraphQL.InputValue(
                    name: "id",
                    description: nil,
                    type: GraphQL.TypeRef.named(.scalar(.id)),
                    defaultValue: nil)
            ],
            type: GraphQL.TypeRef.named(.scalar(.string)),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        XCTAssertEqual(value, expected)
    }
    
    /* TypeRef */
    
    func testDecodeNamedTypeRef() {
        /* Data */
        let json = """
            [
                {
                    "kind": "SCALAR",
                    "name": "String",
                    "ofType": null
                },
                {
                    "kind": "OBJECT",
                    "name": "Human",
                    "ofType": null
                },
                {
                    "kind": "INTERFACE",
                    "name": "Node",
                    "ofType": null
                },
                {
                    "kind": "UNION",
                    "name": "Character",
                    "ofType": null
                },
                {
                    "kind": "ENUM",
                    "name": "Episode",
                    "ofType": null
                },
                {
                    "kind": "INPUT_OBJECT",
                    "name": "HumanParams",
                    "ofType": null
                }
            ]
            """
        
        /* Decoder */
        
        let values = try! JSONDecoder().decode([GraphQL.TypeRef].self, from: json.data(using: .utf8)!)
        
        /* Tests */
        
        XCTAssertEqual(values,
            [
                GraphQL.TypeRef.named(.scalar(.string)),
                GraphQL.TypeRef.named(.object("Human")),
                GraphQL.TypeRef.named(.interface("Node")),
                GraphQL.TypeRef.named(.union("Character")),
                GraphQL.TypeRef.named(.enumeration("Episode")),
                GraphQL.TypeRef.named(.inputObject("HumanParams"))
            ]
        )
    }
    
    func testDecodeNestedTypeRef() {
        let data = [
            (
                """
                {
                    "kind": "ENUM",
                    "name": "Episode",
                    "ofType": null
                }
                """,
                 GraphQL.TypeRef.named(.enumeration("Episode"))
            ),
            (
                """
                {
                    "kind": "NON_NULL",
                    "name": null,
                    "ofType": {
                      "kind": "SCALAR",
                      "name": "ID",
                      "ofType": null
                    }
                }
                """,
                 GraphQL.TypeRef.nonNull(.named(.scalar(.id)))
            ),
            (
                """
                {
                  "kind": "NON_NULL",
                  "name": null,
                  "ofType": {
                    "kind": "LIST",
                    "name": null,
                    "ofType": {
                      "kind": "NON_NULL",
                      "name": null,
                      "ofType": {
                        "kind": "OBJECT",
                        "name": "Human",
                        "ofType": null
                      }
                    }
                  }
                }
                """,
                GraphQL.TypeRef.nonNull(.list(.nonNull(.named(.object("Human")))))
            ),
        ]
        
        /* Tests */
        
        data.forEach { (json, expected) in
            XCTAssertEqual(
                try! JSONDecoder().decode(GraphQL.TypeRef.self, from: json.data(using: .utf8)!),
                expected
            )
        }
    }
    
    func testWrappedNamedType() {
        XCTAssertEqual(
            GraphQL.TypeRef.nonNull(.list(.named(.scalar(.id)))).namedType,
            GraphQL.NamedType.scalar(.id)
        )
        XCTAssertTrue(GraphQL.TypeRef.nonNull(.named(.scalar(.id))).isWrapped)
        XCTAssertFalse(GraphQL.TypeRef.named(.scalar(.id)).isWrapped)
        
    }
    
    /* Named Type */
    
    func testNamedTypeName() {
        let types = [
            GraphQL.NamedType.scalar(GraphQL.Scalar.id),
            GraphQL.NamedType.object("Name"),
            GraphQL.NamedType.interface("Name"),
            GraphQL.NamedType.union("Name"),
            GraphQL.NamedType.enumeration("Name"),
            GraphQL.NamedType.inputObject("Name"),
        ]
        
        XCTAssertEqual(
            types.map { $0.name },
            ["ID", "Name", "Name", "Name", "Name", "Name"]
        )
    }
    
    /* Scalar */
    
    func testDecodeScalar() {
        /* Data, Decoder */
        let data = """
            ["ID", "String", "Boolean", "Int", "Float", "Matic"]
        """.data(using: .utf8)!
        
        let value = try! JSONDecoder().decode([GraphQL.Scalar].self, from: data)
        
        /* Test */
        
        XCTAssertEqual(value, [
            GraphQL.Scalar.id,
            GraphQL.Scalar.string,
            GraphQL.Scalar.boolean,
            GraphQL.Scalar.integer,
            GraphQL.Scalar.float,
            GraphQL.Scalar.custom("Matic"),
        ])
        
    }
    
    func testEncodeScalar() {
        /* Data, Decoder */
        let encoder = try! JSONEncoder().encode([
            GraphQL.Scalar.id,
            GraphQL.Scalar.string,
            GraphQL.Scalar.boolean,
            GraphQL.Scalar.integer,
            GraphQL.Scalar.float,
            GraphQL.Scalar.custom("Matic"),
        ])
        
        let expected = """
            ["ID","String","Boolean","Int","Float","Matic"]
            """
        
        /* Test */
        
        XCTAssertEqual(String(data: encoder, encoding: .utf8)!, expected)
    }
    
    func testScalarIsCustom() {
        XCTAssertTrue(GraphQL.Scalar.custom("Custom").isCustom)
        XCTAssertFalse(GraphQL.Scalar.id.isCustom)
    }
    
    /* Input value */
    
    func testDecodeInputValue() {
//        /* Data */
//        let data = """
//        {
//          "name": "NEWHOPE",
//          "description": "Released in 1977.",
//          "isDeprecated": false,
//          "deprecationReason": null
//        }
//        """.data(using: .utf8)!
//
//        /* Decoder */
//
//        let value = try! JSONDecoder().decode(GraphQL.EnumValue.self, from: data)
//
//        /* Tests */
//
//        let expected = GraphQL.InputValue(
//            name: "NEWHOPE",
//            description: "Released in 1977.",
//            type: GraphQL.TypeRef
//            defaultValue: nil
//        )
//
//        XCTAssertEqual(value, expected)
    }
    
    /* Enum value */
    
    func testDecodeEnumValue() {
        /* Data */
        let data = """
        {
          "name": "NEWHOPE",
          "description": "Released in 1977.",
          "isDeprecated": false,
          "deprecationReason": null
        }
        """.data(using: .utf8)!
        
        /* Decoder */
        
        let value = try! JSONDecoder().decode(GraphQL.EnumValue.self, from: data)
        
        /* Tests */
        
        let expected = GraphQL.EnumValue(
            name: "NEWHOPE",
            description: "Released in 1977.",
            isDeprecated: false,
            deprecationReason: nil
        )
        
        XCTAssertEqual(value, expected)
    }
}
