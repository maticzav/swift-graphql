@testable import SwiftGraphQLCodegen
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

        let values = try! JSONDecoder().decode([GraphQL.NamedTypeRef].self, from: json.data(using: .utf8)!)

        /* Tests */

        XCTAssertEqual(values,
                       [
                           GraphQL.NamedTypeRef.named(.scalar("String")),
                           GraphQL.NamedTypeRef.named(.object("Human")),
                           GraphQL.NamedTypeRef.named(.interface("Node")),
                           GraphQL.NamedTypeRef.named(.union("Character")),
                           GraphQL.NamedTypeRef.named(.enum("Episode")),
                           GraphQL.NamedTypeRef.named(.inputObject("HumanParams")),
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

        let values = try! JSONDecoder().decode([GraphQL.OutputTypeRef].self, from: json.data(using: .utf8)!)

        /* Tests */

        XCTAssertEqual(values,
                       [
                           GraphQL.OutputTypeRef.named(.scalar("String")),
                           GraphQL.OutputTypeRef.named(.object("Human")),
                           GraphQL.OutputTypeRef.named(.interface("Node")),
                           GraphQL.OutputTypeRef.named(.union("Character")),
                           GraphQL.OutputTypeRef.named(.enum("Episode")),
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

        let values = try! JSONDecoder().decode([GraphQL.InputTypeRef].self, from: json.data(using: .utf8)!)

        /* Tests */

        XCTAssertEqual(values,
                       [
                           GraphQL.InputTypeRef.named(.scalar("String")),
                           GraphQL.InputTypeRef.named(.enum("Episode")),
                           GraphQL.InputTypeRef.named(.inputObject("HumanParams")),
                       ])
    }
}
