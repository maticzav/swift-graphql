@testable import GraphQLAST
@testable import SwiftGraphQLCodegen

import XCTest

final class GitHubTests: XCTestCase {
    /// Tests if the generator can generate GitHub GraphQL API schema.
    func testGenerateGitHubSchema() throws {
        guard let apikey = ProcessInfo.processInfo.environment["GH_KEY"] else {
            XCTFail()
            return
        }
        
        let url = URL(string: "https://api.github.com/graphql")!
        let headers = [
            "Authorization": "Bearer \(apikey)"
        ]
        
        let schema = try Schema(from: url, withHeaders: headers)
        let scalars: ScalarMap = [:]
        
        let codegen = GraphQLCodegen(scalars: scalars)
        try codegen.generate(schema: schema)
    }
}
