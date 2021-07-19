@testable import GraphQLAST
@testable import SwiftGraphQLCodegen
import XCTest

final class InputObjectTests: XCTestCase {
    func testInputObjectField() throws {
        /* Type */
        let type = InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .nonNull(.named(.inputObject("AnotherInputObject")))
                ),
                /* Scalar, Docs */
                InputValue(
                    name: "input_value",
                    description: nil,
                    type: .named(.scalar("ID"))
                ),
            ]
        )

        /* Tests */
        let expected = try """
        extension InputObjects {
            struct InputObject: Encodable, Hashable {
                /// Field description.
                var id: InputObjects.AnotherInputObject

                var input_value: OptionalArgument<ID> = .absent()

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(id, forKey: .id)
                    if input_value.hasValue { try container.encode(input_value, forKey: .input_value) }
                }

                enum CodingKeys: String, CodingKey {
                    case id
                    case input_value
                }
            }
        }
        """.format()

        let generated = try type.declaration(scalars: ["ID": "ID"]).format()

        XCTAssertEqual(generated, expected)
    }

    func testEnumField() throws {
        /* Type */
        let type = InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .nonNull(.named(.enum("ENUM")))
                ),
            ]
        )

        /* Tests */

        let expected = try """
        extension InputObjects {
            struct InputObject: Encodable, Hashable {
                /// Field description.
                var id: Enums.ENUM

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(id, forKey: .id)
                }

                enum CodingKeys: String, CodingKey {
                    case id = "id"
                }
            }
        }
        """.format()

        let generated = try type.declaration(scalars: ["ID": "String"]).format()

        XCTAssertEqual(generated, expected)
    }
}
