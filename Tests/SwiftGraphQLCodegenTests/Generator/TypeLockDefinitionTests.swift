import XCTest
@testable import SwiftGraphQLCodegen

final class TypeLockDefinitionTests: XCTestCase {
    func testGeneratePhantomTypes() {
        /* Data */
        let types: [GraphQL.NamedType] = [
            .object(
                GraphQL.ObjectType(
                    name: "Hero",
                    description: nil,
                    fields: [],
                    interfaces: []
                )
            ),
            .inputObject(
                GraphQL.InputObjectType(
                    name: "Human",
                    description: nil,
                    inputFields: []
                )
            )
        ]
        
        /* Types */
        
        let expected = """
        enum Object {
            enum Hero {}
            enum Human {}
        }

        typealias HeroObject = Object.Hero
        typealias HumanObject = Object.Human
        """
        
        XCTAssertEqual(
            GraphQLCodegen.generatePhantomTypes(for: types),
            expected
        )
    }
}
