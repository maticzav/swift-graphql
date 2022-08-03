import Foundation
import GraphQLAST
@testable import SwiftGraphQLCodegen

extension Context {
    /// Creates a mocking context that may be used in tests containing provided scalars.
    static func from(scalars: [String: String]) -> Context {
        let schema = Schema(
            types: [
                .object(ObjectType(name: "Query", description: nil, fields: [], interfaces: nil))
            ],
            query: "Query",
            mutation: nil,
            subscription: nil
        )
        return Context(schema: schema, scalars: ScalarMap(scalars: scalars))
    }
}
