import XCTest
import Files
@testable import SwiftGraphQLCodegen


final class GeneratorTests: XCTestCase {
    func testGenerateTarget() throws {
        /* Target */
        let tmp = try Folder.temporary.createSubfolderIfNeeded(at: "SwiftGraphQL")
        
        try tmp.empty()
        let target = try tmp.createFile(at: "API.swift").url
        
        /* Fetching */
        let endpoint = URL(string: "http://localhost:4000")!
        try GraphQLCodegen.generate(target, from: endpoint)
        
        /* Tests */
        let generated = try String(contentsOf: target)
        
        XCTAssertTrue(generated.count > 1000)
    }
}
