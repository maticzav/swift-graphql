@testable import GraphQLAST
import XCTest

final class ASTTypeTests: XCTestCase {
    // MARK: - Scalar

    func testScalarType() {
        let json = """
        {
          "kind": "SCALAR",
          "name": "String",
          "description": "It's string!",
          "fields": null,
          "inputFields": null,
          "interfaces": null,
          "enumValues": null,
          "possibleTypes": null
        }
        """

        /* Tests */
        let value = try! JSONDecoder().decode(NamedType.self, from: json.data(using: .utf8)!)
        let expected = NamedType.scalar(
            ScalarType(
                name: "String",
                description: "It's string!"
            )
        )

        XCTAssertEqual(value, expected)
    }

    // MARK: - Object

    func testObjectType() {
        let json = """
        {
          "kind": "OBJECT",
          "name": "Query",
          "description": null,
          "fields": [],
          "inputFields": null,
          "interfaces": [],
          "enumValues": null,
          "possibleTypes": null
        }
        """

        /* Tests */
        let value = try! JSONDecoder().decode(NamedType.self, from: json.data(using: .utf8)!)
        let expected = NamedType.object(
            ObjectType(
                name: "Query",
                description: nil,
                fields: [],
                interfaces: []
            )
        )

        XCTAssertEqual(value, expected)
    }

    // MARK: - Interface

    func testInterfaceType() {
        let json = """
        {
          "kind": "INTERFACE",
          "name": "Character",
          "description": null,
          "fields": [],
          "inputFields": null,
          "interfaces": [],
          "enumValues": null,
          "possibleTypes": [
            {
              "kind": "OBJECT",
              "name": "Droid",
              "ofType": null
            },
            {
              "kind": "OBJECT",
              "name": "Human",
              "ofType": null
            }
          ]
        }
        """

        /* Tests */
        let value = try! JSONDecoder().decode(NamedType.self, from: json.data(using: .utf8)!)
        let expected = NamedType.interface(
            InterfaceType(
                name: "Character",
                description: nil,
                fields: [],
                interfaces: [],
                possibleTypes: [
                    .named(.object("Droid")),
                    .named(.object("Human")),
                ]
            )
        )

        XCTAssertEqual(value, expected)
    }

    // MARK: - Union

    func testUnionType() {
        let json = """
        {
          "kind": "UNION",
          "name": "Union",
          "description": null,
          "fields": null,
          "inputFields": null,
          "interfaces": null,
          "enumValues": null,
          "possibleTypes": [
            {
              "kind": "OBJECT",
              "name": "TypeOne",
              "ofType": null
            },
            {
              "kind": "OBJECT",
              "name": "TypeTwo",
              "ofType": null
            }
          ]
        }
        """

        /* Tests */
        let value = try! JSONDecoder().decode(NamedType.self, from: json.data(using: .utf8)!)
        let expected = NamedType.union(
            UnionType(
                name: "Union",
                description: nil,
                possibleTypes: [
                    .named(.object("TypeOne")),
                    .named(.object("TypeTwo")),
                ]
            )
        )

        XCTAssertEqual(value, expected)
    }

    // MARK: - Enum

    func testEnumType() {
        let json = """
        {
          "kind": "ENUM",
          "name": "Enum",
          "description": "It's an ENUM!",
          "fields": null,
          "inputFields": null,
          "interfaces": null,
          "enumValues": [
            {
              "name": "enumValue",
              "description": null,
              "isDeprecated": false,
              "deprecationReason": null
            }
          ],
          "possibleTypes": null
        }

        """

        /* Tests */
        let value = try! JSONDecoder().decode(NamedType.self, from: json.data(using: .utf8)!)
        let expected = NamedType.enum(
            EnumType(
                name: "Enum",
                description: "It's an ENUM!",
                enumValues: [
                    .init(name: "enumValue", description: nil, isDeprecated: false, deprecationReason: nil),
                ]
            )
        )

        XCTAssertEqual(value, expected)
    }

    // MARK: - Input Object

    func testInputObjectType() {
        let json = """
        {
          "kind": "INPUT_OBJECT",
          "name": "InputObject",
          "description": null,
          "fields": null,
          "inputFields": [
            {
              "name": "inputField",
              "description": "",
              "type": {
                "kind": "ENUM",
                "name": "order_by",
                "ofType": null
              },
              "defaultValue": null
            }
          ],
          "interfaces": null,
          "enumValues": null,
          "possibleTypes": null
        }
        """

        /* Tests */
        let value = try! JSONDecoder().decode(NamedType.self, from: json.data(using: .utf8)!)
        let expected = NamedType.inputObject(
            InputObjectType(
                name: "InputObject",
                description: nil,
                inputFields: [
                    .init(
                        name: "inputField",
                        description: "",
                        type: .named(.enum("order_by"))
                    ),
                ]
            )
        )

        XCTAssertEqual(value, expected)
    }
}
