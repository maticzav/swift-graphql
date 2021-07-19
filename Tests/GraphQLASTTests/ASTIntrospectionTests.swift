@testable import GraphQLAST
import XCTest

final class ASTIntrospectionTests: XCTestCase {
    /* Schema */

    func testIntrospectServer() throws {
        let url = URL(string: "https://swapi-ql.herokuapp.com/graphql")!
        let schema = try Schema(from: url)

        /* Tests */

        XCTAssertNotNil(schema)
    }
}
