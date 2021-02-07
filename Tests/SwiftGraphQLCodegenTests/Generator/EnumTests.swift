@testable import GraphQLAST
@testable import SwiftGraphQLCodegen

import XCTest

final class EnumTests: XCTestCase {
    func testGenerateEnum() throws {
        /* Declaration */

        let type = EnumType(
            name: "Episodes",
            description: "Collection of all StarWars episodes.",
            enumValues: [
                EnumValue(
                    name: "NEWHOPE",
                    description: "Released in 1977.",
                    isDeprecated: false,
                    deprecationReason: nil
                ),
                EnumValue(
                    name: "EMPIRE",
                    description: nil,
                    isDeprecated: false,
                    deprecationReason: nil
                ),
                EnumValue(
                    name: "JEDI",
                    description: "Released in 1983.",
                    isDeprecated: true,
                    deprecationReason: "Was too good."
                ),
                EnumValue(
                    name: "SKYWALKER",
                    description: nil,
                    isDeprecated: true,
                    deprecationReason: nil
                ),
            ]
        )

        let generated = try type.declaration.format()

        let expected = try """
        extension Enums {
            /// Collection of all StarWars episodes.
            enum Episodes: String, CaseIterable, Codable {
                /// Released in 1977.

                case newhope = "NEWHOPE"

                case empire = "EMPIRE"
                /// Released in 1983.
                @available(*, deprecated, message: "Was too good.")
                case jedi = "JEDI"

                @available(*, deprecated, message: "")
                case skywalker = "SKYWALKER"
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }
}
