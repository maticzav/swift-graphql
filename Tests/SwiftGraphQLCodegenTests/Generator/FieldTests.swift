@testable import GraphQLAST
@testable import SwiftGraphQLCodegen
import XCTest

final class FieldTests: XCTestCase {
    
    // MARK: - Tests
    
    func testFieldDocs() throws {
        let field = Field(
            name: "id",
            description: "Object identifier.\nMultiline.",
            args: [],
            type: .named(.scalar("ID")),
            isDeprecated: true,
            deprecationReason: "Use ID instead."
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        ).format()

        assertSnapshot(matching: generated)
    }

    // MARK: - Scalar

    func testScalarField() throws {
        let field = Field(
            name: "id",
            description: nil,
            args: [],
            type: .nonNull(.named(.scalar("ID"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func id() throws -> String {
            let field = GraphQLField.leaf(
                name: "id",
                arguments: []
            )
            self.select(field)

            switch self.state {
            case .decoding(let data):
                if let data = data.id[field.alias!] {
                    return data
                }
                throw HttpError.badpayload
            case .mocking:
                return String.mockValue
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testNullableScalarField() throws {
        let field = Field(
            name: "id",
            description: nil,
            args: [],
            type: .named(.scalar("ID")),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func id() throws -> String? {
            let field = GraphQLField.leaf(
                name: "id",
                arguments: []
            )
            self.select(field)

            switch self.state {
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
        let field = Field(
            name: "ids",
            description: nil,
            args: [],
            type: .list(.nonNull(.named(.scalar("ID")))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func ids() throws -> [String]? {
            let field = GraphQLField.leaf(
                name: "ids",
                arguments: []
            )
            self.select(field)

            switch self.state {
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
        let field = Field(
            name: "ids",
            description: nil,
            args: [],
            type: .nonNull(.list(.nonNull(.named(.scalar("ID"))))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func ids() throws -> [String] {
            let field = GraphQLField.leaf(
                name: "ids",
                arguments: []
            )
            self.select(field)

            switch self.state {
            case .decoding(let data):
                if let data = data.ids[field.alias!] {
                    return data
                }
                throw HttpError.badpayload
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
        let field = Field(
            name: "episode",
            description: nil,
            args: [],
            type: .nonNull(.named(.enum("Episode"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func episode() throws -> Enums.Episode {
            let field = GraphQLField.leaf(
                name: "episode",
                arguments: []
            )
            self.select(field)

            switch self.state {
            case .decoding(let data):
                if let data = data.episode[field.alias!] {
                    return data
                }
                throw HttpError.badpayload
            case .mocking:
                return Enums.Episode.allCases.first!
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testNullableEnumField() throws {
        let field = Field(
            name: "episode",
            description: nil,
            args: [],
            type: .named(.enum("Episode")),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func episode() throws -> Enums.Episode? {
            let field = GraphQLField.leaf(
                name: "episode",
                arguments: []
            )
            self.select(field)

            switch self.state {
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
        let field = Field(
            name: "episode",
            description: nil,
            args: [],
            type: .nonNull(.list(.named(.enum("Episode")))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let expected = try """
        func episode() throws -> [Enums.Episode?] {
            let field = GraphQLField.leaf(
                name: "episode",
                arguments: []
            )
            self.select(field)

            switch self.state {
            case .decoding(let data):
                if let data = data.episode[field.alias!] {
                    return data
                }
                throw HttpError.badpayload
            case .mocking:
                return []
            }
        }
        """.format()

        /* Test */

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        XCTAssertEqual(generated, expected)
    }

    // MARK: - Selections

    func testSelectionField() throws {
        let field = Field(
            name: "hero",
            description: nil,
            args: [],
            type: .nonNull(.named(.object("Hero"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func hero<Type>(selection: Selection<Type, Objects.Hero>) throws -> Type {
            let field = GraphQLField.composite(
                name: "hero",
                arguments: [],
                selection: selection.selection
            )
            self.select(field)

            switch self.state {
            case .decoding(let data):
                if let data = data.hero[field.alias!] {
                    return try selection.decode(data: data)
                }
                throw HttpError.badpayload
            case .mocking:
                return selection.mock()
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testNullableSelectionField() throws {
        let field = Field(
            name: "hero",
            description: nil,
            args: [],
            type: .named(.object("Hero")),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func hero<Type>(selection: Selection<Type, Objects.Hero?>) throws -> Type {
            let field = GraphQLField.composite(
                name: "hero",
                arguments: [],
                selection: selection.selection
            )
            self.select(field)

            switch self.state {
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
        let field = Field(
            name: "hero",
            description: nil,
            args: [],
            type: .nonNull(.list(.nonNull(.named(.object("Hero"))))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func hero<Type>(selection: Selection<Type, [Objects.Hero]>) throws -> Type {
            let field = GraphQLField.composite(
                name: "hero",
                arguments: [],
                selection: selection.selection
            )
            self.select(field)

            switch self.state {
            case .decoding(let data):
                if let data = data.hero[field.alias!] {
                    return try selection.decode(data: data)
                }
                throw HttpError.badpayload
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
        let field = Field(
            name: "hero",
            description: nil,
            args: [
                InputValue(
                    name: "id",
                    description: nil,
                    type: .nonNull(.named(.scalar("ID")))
                ),
            ],
            type: .nonNull(.named(.scalar("ID"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func hero(id: String) throws -> String {
            let field = GraphQLField.leaf(
                name: "hero",
                arguments: [Argument(name: "id", type: "ID!", value: id)]
            )
            self.select(field)

            switch self.state {
            case .decoding(let data):
                if let data = data.hero[field.alias!] {
                    return data
                }
                throw HttpError.badpayload
            case .mocking:
                return String.mockValue
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testFieldWithOptionalArgument() throws {
        let field = Field(
            name: "hero",
            description: nil,
            args: [
                InputValue(
                    name: "id",
                    description: nil,
                    type: .named(.scalar("ID"))
                ),
            ],
            type: .nonNull(.named(.scalar("ID"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func hero(id: OptionalArgument<String> = .absent()) throws -> String {
            let field = GraphQLField.leaf(
                name: "hero",
                arguments: [Argument(name: "id", type: "ID", value: id)]
            )
            self.select(field)

            switch self.state {
            case .decoding(let data):
                if let data = data.hero[field.alias!] {
                    return data
                }
                throw HttpError.badpayload
            case .mocking:
                return String.mockValue
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }

    func testFieldWithInputObjectArgument() throws {
        let field = Field(
            name: "hero",
            description: nil,
            args: [
                InputValue(
                    name: "id",
                    description: nil,
                    type: .nonNull(.named(.inputObject("Input")))
                ),
            ],
            type: .nonNull(.named(.scalar("ID"))),
            isDeprecated: false,
            deprecationReason: nil
        )

        let generated = try field.getDynamicSelection(
            context: Context.from(scalars: ["ID": "String"])
        )

        let expected = try """
        func hero(id: InputObjects.Input) throws -> String {
            let field = GraphQLField.leaf(
                name: "hero",
                arguments: [Argument(name: "id", type: "Input!", value: id)]
            )
            self.select(field)

            switch self.state {
            case .decoding(let data):
                if let data = data.hero[field.alias!] {
                    return data
                }
                throw HttpError.badpayload
            case .mocking:
                return String.mockValue
            }
        }
        """.format()

        /* Test */

        XCTAssertEqual(generated, expected)
    }
}
