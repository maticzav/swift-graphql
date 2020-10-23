import XCTest
@testable import SwiftGraphQLCodegen


final class FieldTests: XCTestCase {
    let generator = GraphQLCodegen(options: GraphQLCodegen.Options())
    
    // MARK: - Tests
    
    func testGenerateFieldDocs() {
        let field = GraphQL.Field(
            name: "id",
            description: "Object identifier.",
            args: [],
            type: .named(.scalar("ID")),
            isDeprecated: true,
            deprecationReason: "Use ID instead."
        )
        
        let expected = """
            /// Object identifier.
            @available(*, deprecated, message: "Use ID instead.")
            func id() -> String? {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "id",
                    arguments: [
                
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return data.id
                }
                return nil
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
    
    // MARK: - Scalar
    
    func testGenerateScalarField() {
        let field = GraphQL.Field(
            name: "id",
            description: nil,
            args: [],
            type: .nonNull(.named(.scalar("ID"))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func id() -> String {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "id",
                    arguments: [
                
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return data.id!
                }
                return String.mockValue
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
  
    func testGenerateNullableScalarField() {
        let field = GraphQL.Field(
            name: "id",
            description: nil,
            args: [],
            type: .named(.scalar("ID")),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func id() -> String? {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "id",
                    arguments: [
                
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return data.id
                }
                return nil
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
    
    func testGenerateListScalarField() {
        let field = GraphQL.Field(
            name: "ids",
            description: nil,
            args: [],
            type: .list(.nonNull(.named(.scalar("ID")))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func ids() -> [String]? {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "ids",
                    arguments: [
                
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return data.ids
                }
                return nil
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
    
    func testGenearateNonNullableListScalarField() {
        let field = GraphQL.Field(
            name: "ids",
            description: nil,
            args: [],
            type: .nonNull(.list(.nonNull(.named(.scalar("ID"))))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func ids() -> [String] {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "ids",
                    arguments: [
                
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return data.ids!
                }
                return []
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
    
    // MARK: - Enumerators
    
    func testGenerateEnumField() {
        let field = GraphQL.Field(
            name: "episode",
            description: nil,
            args: [],
            type: .nonNull(.named(.enum("Episode"))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func episode() -> Episode {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "episode",
                    arguments: [
                
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return data.episode!
                }
                return Episode.allCases.first!
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
    
    
    func testGenerateNullableEnumField() {
        let field = GraphQL.Field(
            name: "episode",
            description: nil,
            args: [],
            type: .named(.enum("Episode")),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func episode() -> Episode? {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "episode",
                    arguments: [
                
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return data.episode
                }
                return nil
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
    
    func testGenerateNullableListEnumField() {
        let field = GraphQL.Field(
            name: "episode",
            description: nil,
            args: [],
            type: .nonNull(.list(.named(.enum("Episode")))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func episode() -> [Episode?] {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "episode",
                    arguments: [
                
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return data.episode!
                }
                return []
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
    
    // MARK: - Selections

    func testGenerateSelectionField() {
        let field = GraphQL.Field(
            name: "hero",
            description: nil,
            args: [],
            type: .nonNull(.named(.object("Hero"))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func hero<Type>(_ selection: Selection<Type, HeroObject>) -> Type {
                /* Selection */
                let field = GraphQLField.composite(
                    name: "hero",
                    arguments: [
                
                    ],
                    selection: selection.selection
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return selection.decode(data: data.hero!)
                }
                return selection.mock()
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
    
    func testGenerateNullableSelectionField() {
        let field = GraphQL.Field(
            name: "hero",
            description: nil,
            args: [],
            type: .named(.object("Hero")),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func hero<Type>(_ selection: Selection<Type, HeroObject?>) -> Type {
                /* Selection */
                let field = GraphQLField.composite(
                    name: "hero",
                    arguments: [
                
                    ],
                    selection: selection.selection
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return data.hero.map { selection.decode(data: $0) } ?? selection.mock()
                }
                return selection.mock()
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }

    func testGenerateListSelectionField() {
        let field = GraphQL.Field(
            name: "hero",
            description: nil,
            args: [],
            type: .nonNull(.list(.nonNull(.named(.object("Hero"))))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func hero<Type>(_ selection: Selection<Type, [HeroObject]>) -> Type {
                /* Selection */
                let field = GraphQLField.composite(
                    name: "hero",
                    arguments: [
                
                    ],
                    selection: selection.selection
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return selection.decode(data: data.hero!)
                }
                return selection.mock()
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
    
    // MARK: - Arguments
    
    func testGenerateFieldWithArguments() {
        let field = GraphQL.Field(
            name: "hero",
            description: nil,
            args: [
                GraphQL.InputValue(
                    name: "id",
                    description: nil,
                    type: .nonNull(.named(.scalar("ID")))
                )
            ],
            type: .nonNull(.named(.scalar("ID"))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func hero(id: String) -> String {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "hero",
                    arguments: [
                        Argument(name: "id", value: id),
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response {
                    return data.hero!
                }
                return String.mockValue
            }
        """
        
        /* Test */
        
        XCTAssertEqual(generator.generateField(field), expected)
    }
}


