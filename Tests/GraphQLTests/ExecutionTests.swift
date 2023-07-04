import GraphQL
import XCTest

/// A suite of tests that check all edge cases of the response format as described in [GraphQL Spec Response Format](http://spec.graphql.org/October2021/#sec-Response-Format) section.
final class ExecutionTests: XCTestCase {
    
    func testExecutionWithDataAndErrors() throws {
        let result: ExecutionResult = """
            {
              "data": "Hello World!",
              "errors": [
                {
                  "message": "Message.",
                  "locations": [ { "line": 6, "column": 7 } ],
                  "path": [ "hero", "heroFriends", 1, "name" ]
                }
              ]
            }
            """.decode()
        
        XCTAssertEqual(
            result,
            ExecutionResult(
                data: AnyCodable("Hello World!"),
                errors: [
                    GraphQL.GraphQLError(
                        message: "Message.",
                        locations: [
                            GraphQL.GraphQLError.Location(line: 6, column: 7)
                        ],
                        path: [
                            GraphQL.GraphQLError.PathLink.path("hero"),
                            GraphQL.GraphQLError.PathLink.path("heroFriends"),
                            GraphQL.GraphQLError.PathLink.index(1),
                            GraphQL.GraphQLError.PathLink.path("name")
                        ],
                        extensions: nil
                    )
                ],
                hasNext: nil,
                extensions: nil
            )
        )
    }
    
    func testExecutionWithErrorsField() throws {
        let result: ExecutionResult = """
            {
              "errors": [
                {
                  "message": "Message.",
                  "locations": [ { "line": 6, "column": 7 } ],
                  "path": [ "hero", "heroFriends", 1, "name" ]
                }
              ]
            }
            """.decode()
        
        XCTAssertEqual(
            result,
            GraphQL.ExecutionResult(
                data: nil,
                errors: [
                    GraphQL.GraphQLError(
                        message: "Message.",
                        locations: [
                            GraphQL.GraphQLError.Location(line: 6, column: 7)
                        ],
                        path: [
                            GraphQL.GraphQLError.PathLink.path("hero"),
                            GraphQL.GraphQLError.PathLink.path("heroFriends"),
                            GraphQL.GraphQLError.PathLink.index(1),
                            GraphQL.GraphQLError.PathLink.path("name")
                        ],
                        extensions: nil
                    )
                ],
                hasNext: nil,
                extensions: nil
            )
        )
    }
    
    func testExecutionWithoutErrorsField() throws {
        let result: ExecutionResult = """
            {
              "data": "Hello World!"
            }
            """.decode()
        
        XCTAssertEqual(
            result,
            GraphQL.ExecutionResult(
                data: AnyCodable("Hello World!"),
                errors: nil,
                hasNext: nil,
                extensions: nil
            )
        )
    }
    
    func testExecutionWithErrorsWithExtensions() throws {
        let result: ExecutionResult = """
            {
              "errors": [
                {
                  "message": "Bad Request Exception",
                  "extensions": {
                    "code": "BAD_USER_INPUT",
                  }
                }
              ],
              "data": null
            }
            """.decode()
        
        XCTAssertEqual(
            result,
            GraphQL.ExecutionResult(
                data: nil,
                errors: [
                    GraphQL.GraphQLError(
                        message: "Bad Request Exception",
                        locations: nil,
                        path: nil,
                        extensions: [
                            "code": AnyCodable("BAD_USER_INPUT")
                        ]
                    )
                ],
                hasNext: nil,
                extensions: nil
            )
        )
    }
}


extension String {
    /// Converts a string representation of a GraphQL result into the execution result if possible.
    fileprivate func decode() -> ExecutionResult {
        let decoder = JSONDecoder()
        return try! decoder.decode(ExecutionResult.self, from: self.data(using: .utf8)!)
    }
}
