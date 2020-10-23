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
        let document = [
            GraphQLField.leaf(
                name: "fruit", arguments: [
                    Argument(name: "name", value: "apple")
                ]
            )
        ]
        
        /* Test */
        
        let query = """
        query {
          fruit(name: "apple")
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    func testNestedFieldWithArgument() {
        let document = [
            GraphQLField.composite(
                name: "cart",
                arguments: [
                    Argument(name: "name", value: "apple")
                ],
                selection: [
                    GraphQLField.leaf(name: "items"),
                    GraphQLField.leaf(name: "total"),
                ]
            ),
            GraphQLField.leaf(name: "fruit")
        ]
        
        /* Test */
        
        let query = """
        query {
          cart(name: "apple") {
            items
            total
          }
          fruit
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
}
