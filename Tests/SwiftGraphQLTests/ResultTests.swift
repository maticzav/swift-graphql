import XCTest
@testable import SwiftGraphQL

final class ParserTests: XCTestCase {
    func testSuccessfulResponse() throws {
        /* Data */
        let data: Data = """
        {
          "data": "World!"
        }
        """.data(using: .utf8)!
        let selection = Selection<String, String> {
            if let data = $0.response {
                return data
            }
            
            return "wrong"
        }
        
        let result = try GraphQLResult(data, with: selection)
        
        /* Test */
        
        XCTAssertEqual(result.data, "World!")
        XCTAssertEqual(result.errors, nil)
    }
    
    func testFailingResponse() throws {
        /* Data */
        let response: Data = """
        {
          "errors": [
            {
              "message": "Message.",
              "locations": [ { "line": 6, "column": 7 } ],
              "path": [ "hero", "heroFriends", 1, "name" ]
            }
          ],
          "data": "data"
        }
        """.data(using: .utf8)!
        let selection = Selection<String, String> {
            if let data = $0.response {
                return data
            }
            
            return "wrong"
        }
        
        let result = try GraphQLResult(response, with: selection)
        
        /* Test */
        
        XCTAssertEqual(result.data, "data")
        XCTAssertEqual(result.errors, [
            GraphQLError(
                message: "Message.",
                locations: [GraphQLError.Location(line: 6, column: 7)]
            )
        ])
    }
    
    func testGraphQLResultEquality() throws {
        /* Data */
        let data: Data = """
        {
          "data": "World!"
        }
        """.data(using: .utf8)!
        
        let dataWithErrors: Data = """
        {
          "data": "World!",
          "errors": [
            {
              "message": "Message.",
              "locations": [ { "line": 6, "column": 7 } ],
              "path": [ "hero", "heroFriends", 1, "name" ]
            }
          ],
        }
        """.data(using: .utf8)!
        
        let selection = Selection<String, String> {
            if let data = $0.response {
                return data
            }
            
            return "wrong"
        }
        
        /* Test */
        
        XCTAssertEqual(
            try GraphQLResult(data, with: selection),
            try GraphQLResult(data, with: selection)
        )
        
        XCTAssertNotEqual(
            try GraphQLResult(dataWithErrors, with: selection),
            try GraphQLResult(data, with: selection)
        )
    }
}
