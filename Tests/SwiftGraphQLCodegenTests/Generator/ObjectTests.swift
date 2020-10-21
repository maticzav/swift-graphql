import XCTest
@testable import SwiftGraphQLCodegen

final class ObjectTests: XCTestCase {
    /* Generator */
    
    func testGenerateObject() {
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

        extension SelectionSet where TypeLock == RootQuery {

        }
        """
        
        XCTAssertEqual(GraphQLCodegen.generateObject("RootQuery", for: type), expected)
    }
    
    /* TypeLock */
    
    func testObjectTypeLock() {
        XCTAssertEqual(GraphQLCodegen.generateObjectTypeLock(for: "Hero"), "HeroObject")
    }
}
