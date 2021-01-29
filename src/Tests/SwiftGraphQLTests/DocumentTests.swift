import XCTest
@testable import SwiftGraphQL


final class DocumentTests: XCTestCase {
    func testSingleField() {
        
        /* Document */
        let fruit = GraphQLField.leaf(name: "fruit")
        let document = [fruit]
        
        /* Test */
        
        let query = """
        query {
          \(fruit.alias!): fruit
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    func testMultipleFields() {
        
        /* Document */
        let apple = GraphQLField.leaf(name: "apple")
        let banana = GraphQLField.leaf(name: "banana")
        let document = [apple, banana]
        
        /* Test */
        
        let query = """
        query {
          \(apple.alias!): apple
          \(banana.alias!): banana
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    func testNestedFields() {
        
        /* Document */
        let fruit = GraphQLField.leaf(name: "fruit")
        let items = GraphQLField.leaf(name: "items")
        let cart = GraphQLField.composite(
            name: "cart", selection: [items]
        )
        let document = [fruit, cart]
        
        /* Test */
        
        let query = """
        query {
          \(fruit.alias!): fruit
          \(cart.alias!): cart {
            __typename
            \(items.alias!): items
          }
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    // MARK: - Arguments
    
    func testSingleFieldWithArgument() {
        
        /* Document */
        let argument = Argument(name: "name", type: "String!", value: "\"apple\"")
        let fruit = GraphQLField.leaf(
            name: "fruit",
            arguments: [argument]
        )
        let document = [fruit]
        
        /* Test */
        
        let query = """
        query ($\(argument.hash): String!) {
          \(fruit.alias!): fruit(name: $\(argument.hash))
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    func testNestedFieldWithArgument() {
        
        /* Document */
        let argument = Argument(
            name: "name",
            type: "String!",
            value: "\"apple\""
        )
        let fruit = GraphQLField.leaf(name: "fruit")
        let items = GraphQLField.leaf(name: "items")
        let cart = GraphQLField.composite(
            name: "cart",
            arguments: [argument],
            selection: [items]
        )
        let document = [fruit, cart]
        
        /* Test */
        
        let query = """
        query ($\(argument.hash): String!) {
          \(fruit.alias!): fruit
          \(cart.alias!): cart(name: $\(argument.hash)) {
            __typename
            \(items.alias!): items
          }
        }
        """
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    // MARK: - Fragments
    
    func testFragment() {
        
        /* Document */
        let name = GraphQLField.leaf(name: "name")
        let cart = GraphQLField.composite(
            name: "cart",
            selection: [
                GraphQLField.fragment(type: "Fruit", selection: [name])
            ]
        )
        let document = [cart]
        
        /* Test */
        
        let query = """
        query {
          \(cart.alias!): cart {
            __typename
            ...on Fruit {
              \(name.alias!): name
            }
          }
        }
        """
        
        XCTAssertEqual(document.serialize(for: .query), query)
    }
    
    // MARK: - Operation Names
    
    func testOperationName() {
        
        /* Document */
        let fruit = GraphQLField.leaf(name: "fruit")
        let document = [fruit]
        
        /* Test */
        
        let query = """
        query Fruit {
          \(fruit.alias!): fruit
        }
        """
        XCTAssertEqual(document.serialize(for: .query, operationName: "Fruit"), query)
    }
}
