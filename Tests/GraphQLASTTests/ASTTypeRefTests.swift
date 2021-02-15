@testable import GraphQLAST
import XCTest

final class ASTTypeRefTests: XCTestCase {
    // MARK: - Named Ref

    func testNamedRef() {
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

        let values = try! JSONDecoder().decode([NamedTypeRef].self, from: json.data(using: .utf8)!)

        /* Tests */

        XCTAssertEqual(values,
                       [
                           NamedTypeRef.named(.scalar("String")),
                           NamedTypeRef.named(.object("Human")),
                           NamedTypeRef.named(.interface("Node")),
                           NamedTypeRef.named(.union("Character")),
                           NamedTypeRef.named(.enum("Episode")),
                           NamedTypeRef.named(.inputObject("HumanParams")),
                       ])
    }

    // MARK: - Output Ref

    func testOutputRef() {
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
            }
        ]
        """

        /* Decoder */

        let values = try! JSONDecoder().decode([OutputTypeRef].self, from: json.data(using: .utf8)!)

        /* Tests */

        XCTAssertEqual(values,
                       [
                           OutputTypeRef.named(.scalar("String")),
                           OutputTypeRef.named(.object("Human")),
                           OutputTypeRef.named(.interface("Node")),
                           OutputTypeRef.named(.union("Character")),
                           OutputTypeRef.named(.enum("Episode")),
                       ])
    }

    // MARK: - Input Ref

    func testInputdRef() {
        /* Data */
        let json = """
        [
            {
                "kind": "SCALAR",
                "name": "String",
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

        let values = try! JSONDecoder().decode([InputTypeRef].self, from: json.data(using: .utf8)!)

        /* Tests */

        XCTAssertEqual(values,
                       [
                           InputTypeRef.named(.scalar("String")),
                           InputTypeRef.named(.enum("Episode")),
                           InputTypeRef.named(.inputObject("HumanParams")),
                       ])
    }
}
