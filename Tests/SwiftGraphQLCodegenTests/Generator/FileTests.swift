import XCTest
@testable import SwiftGraphQLCodegen


final class FileTests: XCTestCase {
    let generator = GraphQLCodegen(options: GraphQLCodegen.Options())
    
    // MARK: - Tests
    
    func testGenerateFromSchema() throws {
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
            struct Query: GraphQLRootQuery, Codable {
            }
        }

        typealias RootQuery = Objects.Query

        extension SelectionSet where TypeLock == RootQuery {
        }

        // MARK: - Objects



        // MARK: - Enums

        enum Enums {

        }

        // MARK: - Input Objects

        enum InputObjects {

        }
        """
        
        /* Test */
        
        XCTAssertEqual(try generator.generate(from: schema), expected)
    }
}



