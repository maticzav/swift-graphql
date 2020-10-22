import XCTest
@testable import SwiftGraphQLCodegen

final class IntrospectionTests: XCTestCase {
    func testDownloadSchema() throws {
        /* Fetching */
        let endpoint = URL(string: "http://localhost:4000")!
        let schema: GraphQL.Schema = try GraphQLCodegen.downloadFrom(endpoint)
        
        /* Tests */
        
        XCTAssertNotNil(schema)
        XCTAssertEqual(
            schema.objects.map { $0.name },
            [
                "Droid",
                "Human",
                "Query",
            ]
        )
    }
}
