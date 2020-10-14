import XCTest
@testable import SwiftGraphQL


final class FieldTests: XCTestCase {
    func testSingleLeaf() {
        let selection = [GraphQLField.leaf(name: "fruit")]
        let query = """
        query {
          fruit
        }
        """
        XCTAssertEqual(selection.serialize(for: .query), query)
    }
    
    func testNestedFields() {
        let selection = [
            GraphQLField.leaf(name: "fruit"),
            GraphQLField.composite(name: "cart", selection: [
                GraphQLField.leaf(name: "items"),
                GraphQLField.leaf(name: "total"),
            ])
        ]
        let query = """
        query {
          fruit
          cart {
            items
            total
          }
        }
        """
        XCTAssertEqual(selection.serialize(for: .query), query)
    }
}
