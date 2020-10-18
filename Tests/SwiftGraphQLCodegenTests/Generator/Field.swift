import XCTest
@testable import SwiftGraphQLCodegen


final class FieldTests: XCTestCase {
    func testGenerateFieldWithoutDescription() {
        let field = GraphQL.Field(
            name: "id",
            description: nil,
            args: [],
            type: .named(.scalar(.id)),
            isDeprecated: false,
            deprecationReason: nil
        )
        
        let expected = """
        /// id

        func id() -> String? {
            /* Selection */
            let field = GraphQLField.leaf(name: "id")
            self.select(field)

            /* Decoder */
            if let data = self.response {
                return (data as! [String: Any])[field.name] as! String?
            }
            return "8378"
        }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
    }
  
    func testGenerateDepreactedField() {
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
            let field = GraphQLField.leaf(name: "id")
            self.select(field)

            /* Decoder */
            if let data = self.response {
                return (data as! [String: Any])[field.name] as! String?
            }
            return "8378"
        }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateField(field), expected)
    }
  
}


