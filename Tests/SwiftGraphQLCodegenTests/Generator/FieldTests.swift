import XCTest
@testable import SwiftGraphQLCodegen


final class FieldTests: XCTestCase {
    func testGenerateFieldDocs() {
        let field = GraphQL.Field(
            name: "id",
            description: "Object identifier.",
            args: [],
            type: .named(.scalar(.id)),
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
                if let data = self.response as? [String: Any] {
                    return data[field.name] as! String?
                }
                return nil
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
    }
    
    // MARK: - Scalar
    
    func testGenerateScalarField() {
        let field = GraphQL.Field(
            name: "id",
            description: nil,
            args: [],
            type: .nonNull(.named(.scalar(.id))),
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
                if let data = self.response as? [String: Any] {
                    return data[field.name] as! String
                }
                return "8378"
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
    }
  
    func testGenerateNullableScalarField() {
        let field = GraphQL.Field(
            name: "id",
            description: nil,
            args: [],
            type: .named(.scalar(.id)),
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
                if let data = self.response as? [String: Any] {
                    return data[field.name] as! String?
                }
                return nil
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
    }
    
    func testGenerateListScalarField() {
        let field = GraphQL.Field(
            name: "id",
            description: nil,
            args: [],
            type: .list(.nonNull(.named(.scalar(.id)))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func id() -> [String]? {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "id",
                    arguments: [
                
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response as? [String: Any] {
                    return data[field.name] as! [String]?
                }
                return nil
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
    }
    
    func testGenearateNonNullableListScalarField() {
        let field = GraphQL.Field(
            name: "id",
            description: nil,
            args: [],
            type: .nonNull(.list(.nonNull(.named(.scalar(.id))))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func id() -> [String] {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "id",
                    arguments: [
                
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response as? [String: Any] {
                    return data[field.name] as! [String]
                }
                return []
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
    }
    
    // MARK: - Enumerators
    
    func testGenerateEnumField() {
        let field = GraphQL.Field(
            name: "episode",
            description: nil,
            args: [],
            type: .nonNull(.named(.enumeration("Episode"))),
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
                if let data = self.response as? [String: Any] {
                    return Episode.init(rawValue: data[field.name] as! String)!
                }
                return Episode.allCases.first!
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
    }
    
    
    func testGenerateNullableEnumField() {
        let field = GraphQL.Field(
            name: "episode",
            description: nil,
            args: [],
            type: .named(.enumeration("Episode")),
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
                if let data = self.response as? [String: Any] {
                    return (data[field.name] as! String?).map { Episode.init(rawValue: $0)! }
                }
                return nil
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
    }
    
    func testGenerateNullableListEnumField() {
        let field = GraphQL.Field(
            name: "episode",
            description: nil,
            args: [],
            type: .nonNull(.list(.named(.enumeration("Episode")))),
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
                if let data = self.response as? [String: Any] {
                    return (data[field.name] as! [String?]).map { $0.map { Episode.init(rawValue: $0)! } }
                }
                return []
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
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
                if let data = self.response as? [String: Any] {
                    return selection.decode(data: (data[field.name] as! Any))
                }
                return selection.mock()
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
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
                if let data = self.response as? [String: Any] {
                    return (data[field.name] as! Any?).map { selection.decode(data: $0) } ?? selection.mock()
                }
                return selection.mock()
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
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
                if let data = self.response as? [String: Any] {
                    return selection.decode(data: (data[field.name] as! [Any]))
                }
                return selection.mock()
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
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
                    type: .nonNull(.named(.scalar(.id))),
                    defaultValue: nil
                )
            ],
            type: .nonNull(.named(.scalar(.id))),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
            func hero(id: String) -> String {
                /* Selection */
                let field = GraphQLField.leaf(
                    name: "hero",
                    arguments: [
                        "id": Value.id(id),
                    ]
                )
                self.select(field)
            
                /* Decoder */
                if let data = self.response as? [String: Any] {
                    return data[field.name] as! String
                }
                return "8378"
            }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
    }
}


