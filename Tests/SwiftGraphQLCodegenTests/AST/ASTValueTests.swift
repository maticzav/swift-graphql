@testable import SwiftGraphQLCodegen
import XCTest

final class ASTValueTests: XCTestCase {
    // MARK: - Field

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
            args: [
                GraphQL.InputValue(
                    name: "id",
                    description: nil,
                    type: .named(.scalar("ID"))
                ),
            ],
            type: .named(.scalar("String")),
            isDeprecated: false,
            deprecationReason: nil
        )

        XCTAssertEqual(value, expected)
    }

    // MARK: - InputValue

    func testDecodeInputValue() {
        /* Data */
        let data = """
        {
          "name": "id",
          "description": null,
          "type": {
            "kind": "ENUM",
            "name": "order_by",
            "ofType": null
          },
          "defaultValue": null
        }

        """.data(using: .utf8)!

        /* Tests */
        let value = try! JSONDecoder().decode(GraphQL.InputValue.self, from: data)
        let expected = GraphQL.InputValue(
            name: "id",
            description: nil,
            type: .named(.enum("order_by"))
        )

        XCTAssertEqual(value, expected)
    }

    // MARK: - EnumValue

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
