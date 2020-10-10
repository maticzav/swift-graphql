import XCTest
@testable import swift_graphql

final class swift_graphqlTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(swift_graphql().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
