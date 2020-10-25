import XCTest
@testable import SwiftGraphQLCodegen

final class ObjectTests: XCTestCase {
    let generator = GraphQLCodegen(options: GraphQLCodegen.Options())
    
    // MARK: - Tests
    
    func testEmptyObject() throws {
        /* Type */
        let type = GraphQL.ObjectType(
            name: "Query",
            description: nil,
            fields: [],
            interfaces: []
        )
        
        /* Test */
        
        let expected = """
        /* Query */

        extension Objects {
            struct Query: Codable {
            }
        }

        typealias RootQuery = Objects.Query

        extension SelectionSet where TypeLock == RootQuery {
        }
        """
        
        XCTAssertEqual(
            try generator.generateObject("RootQuery", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    /* TypeLock */
    
    func testObjectTypeLock() {
        XCTAssertEqual(generator.generateObjectTypeLock(for: "Hero"), "HeroObject")
    }
}
