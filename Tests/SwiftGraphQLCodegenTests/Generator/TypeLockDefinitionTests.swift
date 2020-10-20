import XCTest
@testable import SwiftGraphQLCodegen

final class TypeLockDefinitionTests: XCTestCase {
    func testGeneratePhantomTypes() {
        /* Data */
        let types = [
            GraphQL.FullType(
                kind: GraphQL.TypeKind.object,
                name: "Hero",
                description: nil,
                fields: nil,
                inputFields: nil,
                interfaces: nil,
                enumValues: nil,
                possibleTypes: nil
            ),
            GraphQL.FullType(
                kind: GraphQL.TypeKind.object,
                name: "Human",
                description: nil,
                fields: nil,
                inputFields: nil,
                interfaces: nil,
                enumValues: nil,
                possibleTypes: nil
            ),
            GraphQL.FullType(
                kind: GraphQL.TypeKind.object,
                name: "Episode",
                description: nil,
                fields: nil,
                inputFields: nil,
                interfaces: nil,
                enumValues: nil,
                possibleTypes: nil
            ),
        ]
        
        /* Types */
        
        let expected = """
        enum Object {
            enum Hero {}
            enum Human {}
            enum Episode {}
        }

        typealias HeroObject = Object.Hero
        typealias HumanObject = Object.Human
        typealias EpisodeObject = Object.Episode
        """
        
        XCTAssertEqual(
            GraphQLCodegen.generatePhantomTypes(for: types),
            expected
        )
    }
}
