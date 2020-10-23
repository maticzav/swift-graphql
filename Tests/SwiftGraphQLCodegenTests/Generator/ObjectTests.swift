import XCTest
@testable import SwiftGraphQLCodegen

final class ObjectTests: XCTestCase {
    let generator = GraphQLCodegen(options: GraphQLCodegen.Options())
    
    // MARK: - Tests
    
    func testEmptyObject() {
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
            struct RootQuery: Codable {

            }
        }

        typealias RootQueryObject = Objects.RootQuery

        extension SelectionSet where TypeLock == RootQuery {

        }
        """
        
        XCTAssertEqual(generator.generateObject("RootQuery", for: type), expected)
    }
    
    /* TypeLock */
    
    func testObjectTypeLock() {
        XCTAssertEqual(generator.generateObjectTypeLock(for: "Hero"), "HeroObject")
    }
}
