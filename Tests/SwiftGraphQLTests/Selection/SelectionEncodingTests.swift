import GraphQL
@testable import SwiftGraphQL
import XCTest

/// Tests that test how we decode selection.
final class SelectionEncodingTests: XCTestCase {
    
    func testValidatingSelection() throws {
        let droid = Selection.Droid<String> { droid in
            let id = try droid.id()
            let name = try droid.name()
            
            guard id == "very complicated id" else {
                
                throw CustomError.invaidid
            }
            
            return name
        }
        
        let selection = Selection.Query<String?> {
            try $0.droid(id: "mck-id", selection: droid.nullable)
        }
        
        let execution = selection.encode()
        
        XCTAssertTrue(execution.query.contains("query"))
        XCTAssertTrue(execution.query.contains("droidquery_"))
        XCTAssertTrue(execution.query.contains("iddroid_"))
        XCTAssertTrue(execution.query.contains("namedroid_"))
    }
    
    enum CustomError: Error {
        case invaidid
    }
}
