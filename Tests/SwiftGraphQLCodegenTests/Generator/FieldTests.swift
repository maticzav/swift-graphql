@testable import GraphQLAST
@testable import SwiftGraphQLCodegen
import XCTest

final class FieldTests: XCTestCase {
    
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()

        generated.assertInlineSnapshot(matching: """
           /// Object identifier.
           /// Multiline.
           @available(*, deprecated, message: "Use ID instead.")
           public func id() throws -> String? {
             let field = GraphQLField.leaf(
               field: "id",
               parent: "TestType",
               arguments: []
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try String?(from: $0) }
             case .selecting:
               return nil
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()

        generated.assertInlineSnapshot(matching: """
           public func id() throws -> String {
             let field = GraphQLField.leaf(
               field: "id",
               parent: "TestType",
               arguments: []
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try String(from: $0) }
             case .selecting:
               return String.mockValue
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()
        
        generated.assertInlineSnapshot(matching: """
           public func id() throws -> String? {
             let field = GraphQLField.leaf(
               field: "id",
               parent: "TestType",
               arguments: []
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try String?(from: $0) }
             case .selecting:
               return nil
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()

        generated.assertInlineSnapshot(matching: """
           public func ids() throws -> [String]? {
             let field = GraphQLField.leaf(
               field: "ids",
               parent: "TestType",
               arguments: []
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try [String]?(from: $0) }
             case .selecting:
               return nil
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()

        generated.assertInlineSnapshot(matching: """
           public func ids() throws -> [String] {
             let field = GraphQLField.leaf(
               field: "ids",
               parent: "TestType",
               arguments: []
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try [String](from: $0) }
             case .selecting:
               return []
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()
        
        generated.assertInlineSnapshot(matching: """
           public func episode() throws -> Enums.Episode {
             let field = GraphQLField.leaf(
               field: "episode",
               parent: "TestType",
               arguments: []
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try Enums.Episode(from: $0) }
             case .selecting:
               return Enums.Episode.mockValue
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()

        generated.assertInlineSnapshot(matching: """
           public func episode() throws -> Enums.Episode? {
             let field = GraphQLField.leaf(
               field: "episode",
               parent: "TestType",
               arguments: []
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try Enums.Episode?(from: $0) }
             case .selecting:
               return nil
             }
           }
           """)
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

        let generated = try field.getDynamicSelection(
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()

        generated.assertInlineSnapshot(matching: """
           public func episode() throws -> [Enums.Episode?] {
             let field = GraphQLField.leaf(
               field: "episode",
               parent: "TestType",
               arguments: []
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try [Enums.Episode?](from: $0) }
             case .selecting:
               return []
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()
        
        generated.assertInlineSnapshot(matching: """
           public func hero<T>(selection: Selection<T, Objects.Hero>) throws -> T {
             let field = GraphQLField.composite(
               field: "hero",
               parent: "TestType",
               type: "Hero",
               arguments: [],
               selection: selection.__selection()
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
             case .selecting:
               return try selection.__mock()
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()
        
        generated.assertInlineSnapshot(matching: """
           public func hero<T>(selection: Selection<T, Objects.Hero?>) throws -> T {
             let field = GraphQLField.composite(
               field: "hero",
               parent: "TestType",
               type: "Hero",
               arguments: [],
               selection: selection.__selection()
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
             case .selecting:
               return try selection.__mock()
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()
        
        generated.assertInlineSnapshot(matching: """
           public func hero<T>(selection: Selection<T, [Objects.Hero]>) throws -> T {
             let field = GraphQLField.composite(
               field: "hero",
               parent: "TestType",
               type: "Hero",
               arguments: [],
               selection: selection.__selection()
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
             case .selecting:
               return try selection.__mock()
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()
        
        generated.assertInlineSnapshot(matching: """
           public func hero(id: String) throws -> String {
             let field = GraphQLField.leaf(
               field: "hero",
               parent: "TestType",
               arguments: [Argument(name: "id", type: "ID!", value: id)]
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try String(from: $0) }
             case .selecting:
               return String.mockValue
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()
        
        generated.assertInlineSnapshot(matching: """
           public func hero(id: OptionalArgument<String> = .init()) throws -> String {
             let field = GraphQLField.leaf(
               field: "hero",
               parent: "TestType",
               arguments: [Argument(name: "id", type: "ID", value: id)]
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try String(from: $0) }
             case .selecting:
               return String.mockValue
             }
           }
           """)
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
            parent: "TestType",
            context: Context.from(scalars: ["ID": "String"])
        ).format()
        
        generated.assertInlineSnapshot(matching: """
           public func hero(id: InputObjects.Input) throws -> String {
             let field = GraphQLField.leaf(
               field: "hero",
               parent: "TestType",
               arguments: [Argument(name: "id", type: "Input!", value: id)]
             )
             self.__select(field)
           
             switch self.__state {
             case .decoding:
               return try self.__decode(field: field.alias!) { try String(from: $0) }
             case .selecting:
               return String.mockValue
             }
           }
           """)
    }
}
