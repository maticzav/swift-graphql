import XCTest
@testable import SwiftGraphQLCodegen


final class FileTests: XCTestCase {
    let generator = GraphQLCodegen(options: GraphQLCodegen.Options())
    
    // MARK: - Tests
    
    func testGenerateFromSchema() {
        let schema = GraphQL.Schema(
            description: nil,
            types: [
                .object(
                    GraphQL.ObjectType(
                        name: "Query",
                        description: nil,
                        fields: [],
                        interfaces: []
                    )
                )
            ],
            queryType: GraphQL.Operation(name: "Query"),
            mutationType: nil,
            subscriptionType: nil
        )
        
        let expected = """
        import SwiftGraphQL

        enum Objects {}

        // MARK: - Operations

        /* Query */

        extension Objects {
            struct RootQuery: Codable {
            }
        }

        typealias RootQueryObject = Objects.RootQuery

        extension SelectionSet where TypeLock == RootQuery {

        }

        // MARK: - Selection



        // MARK: - Enums


        """
        
        /* Test */
        
        XCTAssertEqual(generator.generate(from: schema), expected)
    }
}



