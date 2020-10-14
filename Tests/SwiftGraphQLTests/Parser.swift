import XCTest
@testable import SwiftGraphQL

final class ParserTests: XCTestCase {
    func testSuccessfulResponse() {
        let data: Data = """
        {
          "data": {
            "hello": "World!"
          }
        }
        """.data(using: .utf8)!
        
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let response = GraphQLResponse(
            data:  (json["data"] as? JSONData),
            errors: json["errors"] as? [GraphQLError]
        )
        
        /* Parse */

        let result = response.parse(with: Selection<String, Any> {
            if let data = $0.response {
                return (data as! [String: String])["hello"]!
            }
            
            return "wrong"
        })
        let expected = GraphQLResult(data: "World!", errors: nil)
        
        /* Test */
        
        XCTAssertEqual(result, expected)
    }
    
    func testFailingResponse() {
        let data: Data = """
        {
          "message": "Message.",
          "locations": [ { "line": 6, "column": 7 } ],
          "path": [ "hero", "heroFriends", 1, "name" ]
        }
        """.data(using: .utf8)!
        
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        let error = json as! GraphQLError
        
//        let data: Data = """
//        {
//          "errors": [
//            {
//              "message": "Message.",
//              "locations": [ { "line": 6, "column": 7 } ],
//              "path": [ "hero", "heroFriends", 1, "name" ]
//            }
//          ],
//          "data": {
//            "hero": {
//              "name": "R2-D2",
//              "heroFriends": []
//            }
//          }
//        }
//        """.data(using: .utf8)!
//
//        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//        let response = GraphQLResponse(
//            data:  (json["data"] as! JSONData),
//            errors: (json["errors"] as! [GraphQLError])
//        )
//
//        let result = response.parse(with: Selection<String, Any> { _ in "ignored" })
//        let expected = GraphQLResult(
//            data: "ignored",
//            errors: [
//                GraphQLError(
//                    message: "Message.",
//                    locations: [GraphQLError.Location(line: 6, column: 7)]
//                )
//            ]
//        )
//
//        XCTAssertEqual(result, expected)
    }
}
