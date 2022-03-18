import GraphQL
@testable import SwiftGraphQL
import XCTest

/// Tests that test how we decode selection.
final class SelectionDecodingTests: XCTestCase {
    
    func testRegular() throws {
        let data: Data = """
        {
          "data": "Hello World!"
        }
        """.data(using: .utf8)!

        let selection = Selection<String, String> {
            switch $0.state {
            case let .decoding(data):
                return data
            case .mocking:
                return "wrong"
            }
        }
        
        let result = try selection.decode(raw: data)
        XCTAssertEqual(result.data, "Hello World!")
        XCTAssertEqual(result.errors, nil)
    }

    func testNullable() throws {
        let data: Data = """
        {
          "data": null
        }
        """.data(using: .utf8)!

        let selection = Selection<String?, String?> {
            switch $0.state {
            case let .decoding(data):
                return data
            case .mocking:
                return "wrong"
            }
        }
        
        let result = try selection.decode(raw: data)
        XCTAssertEqual(result.data, nil)
        XCTAssertEqual(result.errors, nil)
    }

    func testList() throws {
        
        let data: Data = """
        {
          "data": [1, 2, 3]
        }
        """.data(using: .utf8)!
        
        let selection = Selection<Int, Int> {
            switch $0.state {
            case let .decoding(data):
                return data
            case .mocking:
                return 0
            }
        }

        let result = try selection.list.decode(data)
        XCTAssertEqual(result.data, [1, 2, 3])
        XCTAssertEqual(result.errors, nil)
    }
    
    func testNonNullableOrError() throws {
        let data: Data = """
        {
          "data": null
        }
        """.data(using: .utf8)!
        
        let selection = Selection<String, String> {
            switch $0.state {
            case let .decoding(data):
                return data
            case .mocking:
                return "wrong"
            }
        }

        XCTAssertThrowsError(try selection.nonNullOrFail.decode(data)) { (error) -> Void in
            XCTAssertEqual(error as? SelectionError, SelectionError.badpayload)
        }
    }

    func testCustomError() throws {
        let data: Data = """
        {
          "data": null
        }
        """.data(using: .utf8)!
        
        let selection = Selection<String, String?> {
            switch $0.state {
            case let .decoding(data):
                guard let data = data else {
                    throw CustomError.null
                }
                return data
            case .mocking:
                return "wrong"
            }
        }

        XCTAssertThrowsError(try selection.decode(raw: data)) { (error) -> Void in
            XCTAssertEqual(error as? CustomError, CustomError.null)
        }
    }
    
    enum CustomError: Error {
        case null
    }

    // MARK: - Mapping

    func testSelectionMapping() throws {
        let data: Data = """
        {
          "data": "right"
        }
        """.data(using: .utf8)!
        
        let selection = Selection<String, String> {
            switch $0.state {
            case let .decoding(data):
                return data
            case .mocking:
                return "wrong"
            }
        }

        let result = try selection.map { $0 == "right" }.decode(data)
        XCTAssertEqual(result.data, true)
        XCTAssertEqual(result.errors, nil)
    }
    
    // MARK: - Errors

    func testResponseWithErrors() throws {
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
            switch $0.state {
            case let .decoding(data):
                return data
            case .mocking:
                return "wrong"
            }
        }

        let result = try selection.decode(response)
        XCTAssertEqual(result.data, "data")
        XCTAssertEqual(result.errors, [
            GraphQLError(
                message: "Message.",
                locations: [GraphQLError.Location(line: 6, column: 7)],
                path: [.path("hero"), .path("heroFriends"), .index(1), .path("name")]
            ),
        ])
    }
}
