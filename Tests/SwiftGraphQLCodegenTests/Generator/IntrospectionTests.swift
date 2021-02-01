@testable import SwiftGraphQLCodegen
import XCTest

final class IntrospectionTests: XCTestCase {
    func testDownloadSchema() throws {
        /* Fetching */
        let endpoint = URL(string: "http://localhost:4000")!
        let schema: GraphQL.Schema = try GraphQLCodegen.downloadFrom(endpoint)

        /* Tests */

        XCTAssertNotNil(schema)
        XCTAssertTrue(!schema.objects.map { $0.name }.isEmpty)
    }
}
