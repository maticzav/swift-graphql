import XCTest
@testable import SwiftGraphQL

final class ParserTests: XCTestCase {
    func testSuccessfulResponse() {
        /* Data */
        let data: Data = """
        {
          "data": {
            "hello": "World!"
          }
        }
        """.data(using: .utf8)!
        let selection = Selection<String, Any> {
            if let data = $0.response {
                return (data as! [String: String])["hello"]!
            }
            
            return "wrong"
        }
        
        let result = GraphQLResult(data, with: selection)
        
        /* Test */
        
        XCTAssertEqual(result.data, "World!")
        XCTAssertEqual(result.errors, nil)
    }
    
    func testFailingResponse() {
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
          "data": {
            "hero": {
              "name": "R2-D2",
              "heroFriends": []
            }
          }
        }
        """.data(using: .utf8)!
        
        let result = GraphQLResult(response, with: Selection<String, Any> { _ in "ignored" })
        
        /* Test */
        
        XCTAssertEqual(result.data, "ignored")
        XCTAssertEqual(result.errors, [
            GraphQLError(
                message: "Message.",
                locations: [GraphQLError.Location(line: 6, column: 7)]
            )
        ])
    }
    
    func testGraphQLResultEquality() {
        /* Data */
        let data: Data = """
        {
          "data": {
            "hello": "World!"
          }
        }
        """.data(using: .utf8)!
        
        let dataWithErrors: Data = """
        {
          "data": {
            "hello": "World!"
          },
          "errors": [
            {
              "message": "Message.",
              "locations": [ { "line": 6, "column": 7 } ],
              "path": [ "hero", "heroFriends", 1, "name" ]
            }
          ],
        }
        """.data(using: .utf8)!
        
        let selection = Selection<String, Any> {
            if let data = $0.response {
                return (data as! [String: String])["hello"]!
            }
            
            return "wrong"
        }
        
        /* Test */
        
        XCTAssertEqual(
            GraphQLResult(data, with: selection),
            GraphQLResult(data, with: selection)
        )
        
        XCTAssertNotEqual(
            GraphQLResult(dataWithErrors, with: selection),
            GraphQLResult(data, with: selection)
        )
    }
}
