import XCTest
@testable import SwiftGraphQLCodegen

final class ObjectTests: XCTestCase {
    /* Generator */
    
    func testGenerateObject() {
        /* Type */
        let type = GraphQL.FullType(
            kind: .object,
            name: "Query",
            description: nil,
            fields: nil,
            inputFields: nil,
            interfaces: nil,
            enumValues: nil,
            possibleTypes: nil
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
