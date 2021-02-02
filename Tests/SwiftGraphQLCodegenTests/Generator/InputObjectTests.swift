@testable import SwiftGraphQLCodegen
import XCTest

final class InputObjectTests: XCTestCase {
    let generator = GraphQLCodegen(options: GraphQLCodegen.Options())

    // MARK: - Tests

    func testEmptyInputObject() throws {
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: []
        )

        /* Tests */
        let expected = try """
        struct InputObjectTest: Encodable, Hashable {

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

            }

            /* CodingKeys */
            enum CodingKeys: String, CodingKey {
            }
        }
        """.format()

        let generated = try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n").format()

        XCTAssertEqual(generated, expected)
    }

    // MARK: - Docs

    func testFieldDocs() throws {
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .named(.scalar("ID"))
                ),
            ]
        )

        /* Tests */
        let expected = try """
        struct InputObjectTest: Encodable, Hashable {
            /// Field description.
            var id: OptionalArgument<String> = .absent()

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                if id.hasValue { try container.encode(id, forKey: .id) }
            }

            /* CodingKeys */
            enum CodingKeys: String, CodingKey {
                case id = "id"
            }
        }
        """.format()

        let generated = try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n").format()

        XCTAssertEqual(generated, expected)
    }

    // MARK: - Fields

    func testOptionalField() throws {
        /* Type */
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "input_value",
                    description: "Field description.",
                    type: .named(.scalar("ID"))
                ),
            ]
        )

        /* Tests */
        let expected = try """
        struct InputObjectTest: Encodable, Hashable {
            /// Field description.
            var inputValue: OptionalArgument<String> = .absent()

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                if inputValue.hasValue { try container.encode(inputValue, forKey: .inputValue) }
            }

            /* CodingKeys */
            enum CodingKeys: String, CodingKey {
                case inputValue = "input_value"
            }
        }
        """.format()

        let generated = try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n").format()

        XCTAssertEqual(generated, expected)
    }

    func testScalarField() throws {
        /* Type */
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .nonNull(.named(.scalar("ID")))
                ),
            ]
        )

        /* Tests */
        let expected = try """
        struct InputObjectTest: Encodable, Hashable {
            /// Field description.
            var id: String

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(id, forKey: .id)
            }

            /* CodingKeys */
            enum CodingKeys: String, CodingKey {
                case id = "id"
            }
        }
        """.format()

        let generated = try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n").format()

        XCTAssertEqual(generated, expected)
    }

    func testInputObjectField() throws {
        /* Type */
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .nonNull(.named(.inputObject("AnotherInputObject")))
                ),
            ]
        )

        /* Tests */
        let expected = try """
        struct InputObjectTest: Encodable, Hashable {
            /// Field description.
            var id: InputObjects.AnotherInputObject

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(id, forKey: .id)
            }

            /* CodingKeys */
            enum CodingKeys: String, CodingKey {
                case id = "id"
            }
        }
        """.format()

        let generated = try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n").format()

        XCTAssertEqual(generated, expected)
    }

    func testEnumField() throws {
        /* Type */
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .nonNull(.named(.enum("ENUM")))
                ),
            ]
        )

        /* Tests */

        let expected = try """
        struct InputObjectTest: Encodable, Hashable {
            /// Field description.
            var id: Enums.Enum

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(id, forKey: .id)
            }

            /* CodingKeys */
            enum CodingKeys: String, CodingKey {
                case id = "id"
            }
        }
        """.format()

        let generated = try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n").format()

        XCTAssertEqual(generated, expected)
    }
}
