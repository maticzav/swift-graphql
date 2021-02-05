@testable import GraphQLAST
import XCTest

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

        let value = try parse(json.data(using: .utf8)!)
        let expected = Schema(
            description: nil,
            types: [
                .object(ObjectType(
                    name: "Human",
                    description: "A humanoid creature in the Star Wars universe.",
                    fields: [
                        Field(
                            name: "name",
                            description: "The name of the character",
                            args: [],
                            type: .named(.scalar("String")),
                            isDeprecated: false,
                            deprecationReason: nil
                        ),
                    ],
                    interfaces: [
                        .named(.interface("Character")),
                    ]
                )),
            ],
            queryType: Operation(name: "Query"),
            mutationType: nil,
            subscriptionType: nil
        )

        /* Tests */

        XCTAssertEqual(value, expected)
    }
}
