import GraphQL
@testable import SwiftGraphQL
import XCTest

/// Tests that test how we decode selection.
final class SelectionEncodingTests: XCTestCase {
    
    func testValidatingSelection() throws {
        let comic = Selection.Comic<String> {
            let id = try $0.id()
            let title = try $0.title()
            
            guard id == "very complicated id" else {
                throw CustomError.invaidid
            }
            
            return title
        }
        
        let selection = Selection.Query<[String]> {
            try $0.comics(selection: comic.list)
        }
        
        let execution = selection.encode()
        
        XCTAssertTrue(execution.query.contains("query"))
        XCTAssertTrue(execution.query.contains("comicsquery_"))
        XCTAssertTrue(execution.query.contains("idcomic_"))
        XCTAssertTrue(execution.query.contains("titlecomic_"))
    }
    
    enum CustomError: Error {
        case invaidid
    }
}
