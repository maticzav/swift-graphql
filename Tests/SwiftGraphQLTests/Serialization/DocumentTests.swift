@testable import SwiftGraphQL
import XCTest

/// Tests the serialization of the query from the AST.
final class DocumentTests: XCTestCase {
    
    func testSingleField() {
        let fruit = GraphQLField.leaf(field: "fruit", parent: "Query", arguments: [])
        let document = [fruit]

        let query = """
        query {
          \(fruit.alias!): fruit
        }
        """
        XCTAssertEqual(document.serialize(for: "query"), query)
    }

    func testMultipleFields() {
        let apple = GraphQLField.leaf(field: "apple", parent: "Query", arguments: [])
        let banana = GraphQLField.leaf(field: "banana", parent: "Query", arguments: [])
        let document = [apple, banana]

        let query = """
        query {
          \(apple.alias!): apple
          \(banana.alias!): banana
        }
        """
        XCTAssertEqual(document.serialize(for: "query"), query)
    }

    func testNestedFields() {
        let fruit = GraphQLField.leaf(field: "fruit", parent: "Query", arguments: [])
        let items = GraphQLField.leaf(field: "items", parent: "Cart", arguments: [])
        let cart = GraphQLField.composite(
            field: "cart",
            parent: "Query",
            type: "Cart",
            arguments: [],
            selection: [items]
        )
        let document = [fruit, cart]

        let query = """
        query {
          \(fruit.alias!): fruit
          \(cart.alias!): cart {
            __typename
            \(items.alias!): items
          }
        }
        """
        XCTAssertEqual(document.serialize(for: "query"), query)
    }

    // MARK: - Arguments

    func testSingleFieldWithArgument() {
        let argument = Argument(name: "name", type: "String!", value: "\"apple\"")
        let fruit = GraphQLField.leaf(
            field: "fruit",
            parent: "Query",
            arguments: [argument]
        )
        let document = [fruit]

        let query = """
        query ($\(argument.hash): String!) {
          \(fruit.alias!): fruit(name: $\(argument.hash))
        }
        """
        XCTAssertEqual(document.serialize(for: "query"), query)
    }

    func testMultipleSameValueArguments() {
        let argumentOne = Argument(name: "one", type: "String!", value: "\"apple\"")
        let argumentTwo = Argument(name: "two", type: "String!", value: "\"apple\"")
        let fruit = GraphQLField.leaf(
            field: "fruit",
            parent: "Query",
            arguments: [argumentOne, argumentTwo]
        )
        let document = [fruit]

        let query = """
        query ($\(argumentOne.hash): String!) {
          \(fruit.alias!): fruit(one: $\(argumentOne.hash), two: $\(argumentTwo.hash))
        }
        """
        XCTAssertEqual(document.serialize(for: "query"), query)
    }

    func testNestedFieldWithArgument() {
        let argument = Argument(
            name: "name",
            type: "String!",
            value: "\"apple\""
        )
        let fruit = GraphQLField.leaf(field: "fruit", parent: "Query", arguments: [])
        let items = GraphQLField.leaf(field: "items", parent: "Cart", arguments: [])
        let cart = GraphQLField.composite(
            field: "cart",
            parent: "Query",
            type: "Cart",
            arguments: [argument],
            selection: [items]
        )
        let document = [fruit, cart]

        let query = """
        query ($\(argument.hash): String!) {
          \(fruit.alias!): fruit
          \(cart.alias!): cart(name: $\(argument.hash)) {
            __typename
            \(items.alias!): items
          }
        }
        """
        XCTAssertEqual(document.serialize(for: "query"), query)
    }

    // MARK: - Fragments

    func testFragment() {
        let name = GraphQLField.leaf(field: "name", parent: "Fruit", arguments: [])
        let cart = GraphQLField.composite(
            field: "cart",
            parent: "Query",
            type: "Cart",
            arguments: [],
            selection: [
                GraphQLField.fragment(type: "Fruit", interface: "Item", selection: [name]),
            ]
        )
        let document = [cart]

        let query = """
        query {
          \(cart.alias!): cart {
            __typename
            ...on Fruit {
              __typename
              \(name.alias!): name
            }
          }
        }
        """

        XCTAssertEqual(document.serialize(for: "query"), query)
    }

    // MARK: - Operation Names

    func testOperationName() {
        let fruit = GraphQLField.leaf(field: "fruit", parent: "Query", arguments: [])
        let document = [fruit]

        let query = """
        query Fruit {
          \(fruit.alias!): fruit
        }
        """
        XCTAssertEqual(document.serialize(for: "query", operationName: "Fruit"), query)
    }
}
