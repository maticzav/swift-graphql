@testable import GraphQLAST
import XCTest

final class ASTIntrospectionTests: XCTestCase {
    /// Test that it's possible to load schema from a URL.
    func testLoadSchemaFromURL() throws {
        let url = URL(string: "http://127.0.0.1:4000/graphql")!
        let schema = try Schema(from: url)

        /* Tests */

        XCTAssertNotNil(schema)
    }
}
