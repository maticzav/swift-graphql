import XCTest
@testable import SwiftGraphQLCodegen


final class FileTests: XCTestCase {
    func testGenerateFromSchema() {
        let schema = GraphQL.Schema(
            types: [
                GraphQL.FullType(
                    kind: .object,
                    name: "Query",
                    description: nil,
                    fields: nil,
                    inputFields: nil,
                    interfaces: nil,
                    enumValues: nil,
                    possibleTypes: nil
                )
            ],
            queryType: GraphQL.Operation(name: "Query"),
            mutationType: nil,
            subscriptionType: nil
        )
        
        let expected = """
        import SwiftGraphQL

        // MARK: - Operations

        /* Query */

        extension SelectionSet where TypeLock == RootQuery {

        }

        // MARK: - Objects

        enum Object {

        }



        // MARK: - Selection



        // MARK: - Enums


        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generate(from: schema), expected)
    }
}



