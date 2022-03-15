import Foundation
import GraphQLAST
@testable import SwiftGraphQLCodegen

extension Context {
    /// Creates a
    static func from(scalars: ScalarMap) -> Context {
        let schema = Schema(
            types: [
                .object(ObjectType(name: "Query", description: nil, fields: [], interfaces: nil))
            ],
            query: "Query",
            mutation: nil,
            subscription: nil
        )
        return Context(schema: schema, scalars: scalars)
    }
}
