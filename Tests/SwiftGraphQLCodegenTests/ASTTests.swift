import XCTest
@testable import SwiftGraphQLCodegen


final class ASTTests: XCTestCase {
    /* Schema */
    
    func testDecodeSchema() throws {
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
        
        let value = try GraphQL.parse(json.data(using: .utf8)!)
        let expected = GraphQL.Schema(
            description: nil,
            types: [
                .object(GraphQL.ObjectType(
                    name: "Human",
                    description: "A humanoid creature in the Star Wars universe.",
                    fields: [
                        GraphQL.Field(
                            name: "name",
                            description: "The name of the character",
                            args: [],
                            type: .named(.scalar("String")),
                            isDeprecated: false,
                            deprecationReason: nil
                        )
                    ],
                    interfaces: [
                        .named(.interface("Character"))
                    ]
                ))
            ],
            queryType: GraphQL.Operation(name: "Query"),
            mutationType: nil,
            subscriptionType: nil
        )
        
        /* Tests */
        
        XCTAssertEqual(value, expected)
    }
}
