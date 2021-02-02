import Files
@testable import SwiftGraphQLCodegen
import XCTest

final class GeneratorTests: XCTestCase {
    let generator = GraphQLCodegen(
        options: GraphQLCodegen.Options(scalarMappings: ["Date": "DateTime"])
    )

    // MARK: - Tests

    func testGenerateTarget() throws {
        /* Target */
        let tmp = try Folder.temporary.createSubfolderIfNeeded(at: "SwiftGraphQL")

        try tmp.empty()
        let target = try tmp.createFile(at: "API.swift").url

        /* Fetching */
        let endpoint = URL(string: "http://localhost:4000")!
        try generator.generate(target, from: endpoint)

        /* Tests */
        let generated = try String(contentsOf: target)

        XCTAssertTrue(generated.count > 1000)
    }
}
