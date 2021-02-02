@testable import SwiftGraphQLCodegen
import XCTest

final class FieldTests: XCTestCase {
    let generator = GraphQLCodegen(options: GraphQLCodegen.Options())

    // MARK: - Tests

    func testFieldDocs() throws {
        let field = GraphQL.Field(
            name: "id",
            description: "Object identifier.",
            args: [],
            type: .named(.scalar("ID")),
            isDeprecated: true,
            deprecationReason: "Use ID instead."
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        /// Object identifier.
        @available(*, deprecated, message: "Use ID instead.")
        func id() throws -> String? {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "id",
                arguments: [
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                return data.id[field.alias!]
            case .mocking:
                return nil
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    // MARK: - Scalar

    func testScalarField() throws {
        let field = GraphQL.Field(
            name: "id",
            description: nil,
            args: [],
            type: .nonNull(.named(.scalar("ID"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func id() throws -> String {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "id",
                arguments: [
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                if let data = data.id[field.alias!] {
                    return data
                }
                throw SG.HttpError.badpayload
            case .mocking:
                return String.mockValue
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testNullableScalarField() throws {
        let field = GraphQL.Field(
            name: "id",
            description: nil,
            args: [],
            type: .named(.scalar("ID")),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func id() throws -> String? {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "id",
                arguments: [
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                return data.id[field.alias!]
            case .mocking:
                return nil
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testListScalarField() throws {
        let field = GraphQL.Field(
            name: "ids",
            description: nil,
            args: [],
            type: .list(.nonNull(.named(.scalar("ID")))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func ids() throws -> [String]? {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "ids",
                arguments: [
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                return data.ids[field.alias!]
            case .mocking:
                return nil
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testGenearateNonNullableListScalarField() throws {
        let field = GraphQL.Field(
            name: "ids",
            description: nil,
            args: [],
            type: .nonNull(.list(.nonNull(.named(.scalar("ID"))))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func ids() throws -> [String] {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "ids",
                arguments: [
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                if let data = data.ids[field.alias!] {
                    return data
                }
                throw SG.HttpError.badpayload
            case .mocking:
                return []
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    // MARK: - Enumerators

    func testEnumField() throws {
        let field = GraphQL.Field(
            name: "episode",
            description: nil,
            args: [],
            type: .nonNull(.named(.enum("Episode"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func episode() throws -> Enums.Episode {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "episode",
                arguments: [
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                if let data = data.episode[field.alias!] {
                    return data
                }
                throw SG.HttpError.badpayload
            case .mocking:
                return Enums.Episode.allCases.first!
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testNullableEnumField() throws {
        let field = GraphQL.Field(
            name: "episode",
            description: nil,
            args: [],
            type: .named(.enum("Episode")),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func episode() throws -> Enums.Episode? {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "episode",
                arguments: [
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                return data.episode[field.alias!]
            case .mocking:
                return nil
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testNullableListEnumField() throws {
        let field = GraphQL.Field(
            name: "episode",
            description: nil,
            args: [],
            type: .nonNull(.list(.named(.enum("Episode")))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let expected = try """
        func episode() throws -> [Enums.Episode?] {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "episode",
                arguments: [
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                if let data = data.episode[field.alias!] {
                    return data
                }
                throw SG.HttpError.badpayload
            case .mocking:
                return []
            }
        }
        """.format()

        /* Test */

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        XCTAssertEqual(generated, expected)
    }

    // MARK: - Selections

    func testSelectionField() throws {
        let field = GraphQL.Field(
            name: "hero",
            description: nil,
            args: [],
            type: .nonNull(.named(.object("Hero"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func hero<Type>(_ selection: Selection<Type, Objects.Hero>) throws -> Type {
            /* Selection */
            let field = GraphQLField.composite(
                name: "hero",
                arguments: [
                ],
                selection: selection.selection
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                if let data = data.hero[field.alias!] {
                    return try selection.decode(data: data)
                }
                throw SG.HttpError.badpayload
            case .mocking:
                return selection.mock()
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testNullableSelectionField() throws {
        let field = GraphQL.Field(
            name: "hero",
            description: nil,
            args: [],
            type: .named(.object("Hero")),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func hero<Type>(_ selection: Selection<Type, Objects.Hero?>) throws -> Type {
            /* Selection */
            let field = GraphQLField.composite(
                name: "hero",
                arguments: [
                ],
                selection: selection.selection
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                return try selection.decode(data: data.hero[field.alias!])
            case .mocking:
                return selection.mock()
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testListSelectionField() throws {
        let field = GraphQL.Field(
            name: "hero",
            description: nil,
            args: [],
            type: .nonNull(.list(.nonNull(.named(.object("Hero"))))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func hero<Type>(_ selection: Selection<Type, [Objects.Hero]>) throws -> Type {
            /* Selection */
            let field = GraphQLField.composite(
                name: "hero",
                arguments: [
                ],
                selection: selection.selection
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                if let data = data.hero[field.alias!] {
                    return try selection.decode(data: data)
                }
                throw SG.HttpError.badpayload
            case .mocking:
                return selection.mock()
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    // MARK: - Arguments

    func testFieldWithScalarArgument() throws {
        let field = GraphQL.Field(
            name: "hero",
            description: nil,
            args: [
                GraphQL.InputValue(
                    name: "id",
                    description: nil,
                    type: .nonNull(.named(.scalar("ID")))
                ),
            ],
            type: .nonNull(.named(.scalar("ID"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func hero(id: String) throws -> String {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "hero",
                arguments: [
                    Argument(name: "id", type: "ID!", value: id),
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                if let data = data.hero[field.alias!] {
                    return data
                }
                throw SG.HttpError.badpayload
            case .mocking:
                return String.mockValue
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testFieldWithOptionalArgument() throws {
        let field = GraphQL.Field(
            name: "hero",
            description: nil,
            args: [
                GraphQL.InputValue(
                    name: "id",
                    description: nil,
                    type: .named(.scalar("ID"))
                ),
            ],
            type: .nonNull(.named(.scalar("ID"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func hero(id: OptionalArgument<String> = .absent) throws -> String {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "hero",
                arguments: [
                    Argument(name: "id", type: "ID", value: id),
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                if let data = data.hero[field.alias!] {
                    return data
                }
                throw SG.HttpError.badpayload
            case .mocking:
                return String.mockValue
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testFieldWithInputObjectArgument() throws {
        let field = GraphQL.Field(
            name: "hero",
            description: nil,
            args: [
                GraphQL.InputValue(
                    name: "id",
                    description: nil,
                    type: .nonNull(.named(.inputObject("Input")))
                ),
            ],
            type: .nonNull(.named(.scalar("ID"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try generator.generateField(field).joined(separator: "\n").format()

        let expected = try """
        func hero(id: InputObjects.Input) throws -> String {
            /* Selection */
            let field = GraphQLField.leaf(
                name: "hero",
                arguments: [
                    Argument(name: "id", type: "Input!", value: id),
                ]
            )
            self.select(field)

            /* Decoder */
            switch self.response {
            case .decoding(let data):
                if let data = data.hero[field.alias!] {
                    return data
                }
                throw SG.HttpError.badpayload
            case .mocking:
                return String.mockValue
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }
}
