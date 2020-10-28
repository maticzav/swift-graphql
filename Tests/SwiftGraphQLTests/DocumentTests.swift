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
            __typename
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
            __typename
            items
            total
          }
          fruit
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    // MARK: - Fragments
    
    func testFragment() {
        let document = [
            GraphQLField.composite(name: "cart", selection: [
                GraphQLField.leaf(name: "id"),
                GraphQLField.fragment(type: "Fruit", selection: [
                    GraphQLField.leaf(name: "name")
                ])
            ])
        ]
        
        /* Test */
        
        let query = """
        query {
          cart {
            __typename
            id
            ...on Fruit {
              name
            }
          }
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
}
