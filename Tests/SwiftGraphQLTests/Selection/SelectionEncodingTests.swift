import GraphQL
@testable import SwiftGraphQL
import XCTest

/// Tests that test how we decode selection.
final class SelectionEncodingTests: XCTestCase {
    
    func testValidatingSelection() throws {
        let character = Selection.Character<String> {
            let id = try $0.id()
            let name = try $0.name()
            
            guard id == "very complicated id" else {
                throw CustomError.invaidid
            }
            
            return name
        }
        
        let selection = Selection.Query<[String]> {
            try $0.characters(selection: character.list)
        }
        
        let execution = selection.encode()
        
        
        XCTAssertTrue(execution.query.contains("query"))
        XCTAssertTrue(execution.query.contains("charactersquery_"))
        XCTAssertTrue(execution.query.contains("idcharacter_"))
        XCTAssertTrue(execution.query.contains("namecharacter_"))
    }
    
    enum CustomError: Error {
        case invaidid
    }
}
