@testable import SwiftGraphQL
import XCTest

final class SelectionTests: XCTestCase {
    // MARK: - Type Wrappers

    func testNullable() throws {
        /* Data */
        let data: Data = """
        {
          "data": null
        }
        """.data(using: .utf8)!

        /* Selection */
        let selection = Selection<String, String> {
            switch $0.response {
            case let .decoding(data):
                return data
            case .mocking:
                return "wrong"
            }
        }

        let result = try GraphQLResult(
            data,
            with: selection.nullable
        )

        /* Test */

        XCTAssertEqual(result.data, nil)
        XCTAssertEqual(result.errors, nil)
    }

    func testList() throws {
        /* Data */
        let data: Data = """
        {
          "data": [1, 2, 3]
        }
        """.data(using: .utf8)!
        let selection = Selection<Int, Int> {
            switch $0.response {
            case let .decoding(data):
                return data
            case .mocking:
                return 0
            }
        }

        let result = try GraphQLResult(
            data,
            with: selection.list.nonNullOrFail
        )

        /* Test */

        XCTAssertEqual(result.data, [1, 2, 3])
        XCTAssertEqual(result.errors, nil)
    }

    func testNonNullable() throws {
        /* Data */
        let data: Data = """
        {
          "data": null
        }
        """.data(using: .utf8)!
        let selection = Selection<String, String> {
            switch $0.response {
            case let .decoding(data):
                print(data)
                return data
            case .mocking:
                return "wrong"
            }
        }

        /* Test */
        XCTAssertThrowsError(
            // Throwing function.
            try GraphQLResult(
                data,
                with: selection.nonNullOrFail
            )
        ) { (error) -> Void in
            // Errors with wrong data.
            XCTAssertEqual(error as? SG.HttpError, SG.HttpError.badpayload)
        }
    }

    // MARK: - Mapping

    func testSelectionMapping() throws {
        /* Data */
        let data: Data = """
        {
          "data": "right"
        }
        """.data(using: .utf8)!
        let selection = Selection<String, String> {
            switch $0.response {
            case let .decoding(data):
                return data
            case .mocking:
                return "wrong"
            }
        }

        let result = try GraphQLResult(
            data,
            with: selection.map { $0 == "right" }.nonNullOrFail
        )

        /* Test */

        XCTAssertEqual(result.data, true)
        XCTAssertEqual(result.errors, nil)
    }
}
