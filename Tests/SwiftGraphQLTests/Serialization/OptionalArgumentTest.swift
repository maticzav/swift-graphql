@testable import SwiftGraphQL
import XCTest

final class OptionalArgumentTests: XCTestCase {
    // MARK: - Recursive types

    func testRecursiveOptionalType() {
        struct Person {
            var name: String
            var friends: OptionalArgument<Person>
        }
    }

    // MARK: - OptionalArgument manipulation

    func testFromMaybe() {
        XCTAssertEqual(OptionalArgument<String>(present: nil), .init(present: nil))
        XCTAssertEqual(OptionalArgument<String>(absent: nil), .init())
        XCTAssertEqual(OptionalArgument(present: "value"), .init(present: "value"))
    }

    func testMapping() {
        XCTAssertEqual(
            OptionalArgument(present: 1).map { $0 + 1 },
            .init(present: 2)
        )
        XCTAssertEqual(
            OptionalArgument(absent: nil).map { $0 + 1 },
            .init()
        )
        XCTAssertEqual(
            OptionalArgument(present: nil).map { $0 + 1 },
            .init(present: nil)
        )
    }
}
