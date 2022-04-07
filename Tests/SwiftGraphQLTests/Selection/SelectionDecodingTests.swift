import GraphQL
@testable import SwiftGraphQL
import XCTest

/// Tests that test how we decode selection.
final class SelectionDecodingTests: XCTestCase {
    
    func testRegular() throws {
        let result: ExecutionResult = """
            {
              "data": "Hello World!"
            }
            """.execution()

        let selection = Selection<String, String> {
            switch $0.__state {
            case let .decoding(data):
                return try String(from: data)
            case .selecting:
                return "wrong"
            }
        }
        
        let decoded = try selection.decode(raw: result.data)
        XCTAssertEqual(decoded, "Hello World!")
        XCTAssertEqual(result.errors, nil)
    }

    func testNullable() throws {
        let result: ExecutionResult = """
            {
              "data": null
            }
            """.execution()

        let selection = Selection<String?, String?> {
            switch $0.__state {
            case let .decoding(data):
                return try String?(from: data)
            case .selecting:
                return "wrong"
            }
        }
        
        let decoded = try selection.decode(raw: result.data)
        XCTAssertEqual(decoded, nil)
        XCTAssertEqual(result.errors, nil)
    }

    func testList() throws {
        
        let result: ExecutionResult = """
            {
              "data": [1, 2, 3]
            }
            """.execution()
        
        let selection = Selection<Int, Int> {
            switch $0.__state {
            case let .decoding(data):
                return try Int(from: data)
            case .selecting:
                return 0
            }
        }

        let decoded = try selection.list.decode(raw: result.data)
        XCTAssertEqual(decoded, [1, 2, 3])
        XCTAssertEqual(result.errors, nil)
    }
    
    func testNonNullableOrError() throws {
        let result: ExecutionResult = """
            {
              "data": null
            }
            """.execution()
        
        let selection = Selection<String, String> {
            switch $0.__state {
            case let .decoding(data):
                return try String(from: data)
            case .selecting:
                return "wrong"
            }
        }

        XCTAssertThrowsError(try selection.nonNullOrFail.decode(raw: result.data)) { (error) -> Void in
            XCTAssertEqual(error as! ObjectDecodingError, ObjectDecodingError.unexpectedNilValue)
        }
    }

    func testCustomError() throws {
        let result: ExecutionResult = """
            {
              "data": null
            }
            """.execution()
        
        let selection = Selection<String, String?> {
            switch $0.__state {
            case .decoding:
                throw CustomError.null
            case .selecting:
                return "wrong"
            }
        }

        XCTAssertThrowsError(try selection.decode(raw: result.data)) { (error) -> Void in
            XCTAssertEqual(error as? CustomError, CustomError.null)
        }
    }
    
    enum CustomError: Error {
        case null
    }

    // MARK: - Mapping

    func testSelectionMapping() throws {
        let result: ExecutionResult = """
        {
          "data": "right"
        }
        """.execution()
        
        let selection = Selection<String, String> {
            switch $0.__state {
            case let .decoding(data):
                return try String(from: data)
            case .selecting:
                return "wrong"
            }
        }

        let decoded = try selection.map { $0 == "right" }.decode(raw: result.data)
        XCTAssertEqual(decoded, true)
        XCTAssertEqual(result.errors, nil)
    }
    
    // MARK: - Errors

    func testResponseWithErrors() throws {
        let result: ExecutionResult = """
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
            """.execution()
        
        let selection = Selection<String, String> {
            switch $0.__state {
            case let .decoding(data):
                return try String(from: data)
            case .selecting:
                return "wrong"
            }
        }

        let decoded = try selection.decode(raw: result.data)
        XCTAssertEqual(decoded, "data")
        XCTAssertEqual(result.errors, [
            GraphQLError(
                message: "Message.",
                locations: [GraphQLError.Location(line: 6, column: 7)],
                path: [.path("hero"), .path("heroFriends"), .index(1), .path("name")]
            ),
        ])
    }
}

extension String {
    
    /// Converts a string representation of a GraphQL result into the execution result that may be used to
    /// test selection result..
    fileprivate func execution() -> ExecutionResult {
        let decoder = JSONDecoder()
        return try! decoder.decode(ExecutionResult.self, from: self.data(using: .utf8)!)
    }
}
