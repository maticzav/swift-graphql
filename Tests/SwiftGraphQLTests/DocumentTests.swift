import XCTest
@testable import SwiftGraphQL


final class DocumentTests: XCTestCase {
    func testSingleField() {
        let document = [GraphQLField.leaf(name: "fruit")]
        
        /* Test */
        
        let query = """
        query {
          fruit
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    func testNestedFields() {
        let document = [
            GraphQLField.leaf(name: "fruit"),
            GraphQLField.composite(name: "cart", selection: [
                GraphQLField.leaf(name: "items"),
                GraphQLField.leaf(name: "total"),
            ])
        ]
        
        /* Test */
        
        let query = """
        query {
          fruit
          cart {
            items
            total
          }
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    // MARK: - Arguments
    
    func testSingleFieldWithArgument() {
        let argument = Argument(name: "name", type: "String!", value: "\"apple\"")
        let document = [
            GraphQLField.leaf(
                name: "fruit",
                arguments: [argument]
            )
        ]
        
        /* Test */
        
        let query = """
        query($\(argument.hash): String!) {
          fruit(name: $\(argument.hash))
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    func testNestedFieldWithArgument() {
        let argument = Argument(name: "name", type: "String!", value: "\"apple\"")
        let document = [
            GraphQLField.composite(
                name: "cart",
                arguments: [argument],
                selection: [
                    GraphQLField.leaf(name: "items"),
                    GraphQLField.leaf(name: "total"),
                ]
            ),
            GraphQLField.leaf(name: "fruit")
        ]
        
        /* Test */
        
        let query = """
        query($\(argument.hash): String!) {
          cart(name: $\(argument.hash)) {
            items
            total
          }
          fruit
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
}
