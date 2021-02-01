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
        XCTAssertEqual(OptionalArgument<String>(nil), .null())
        XCTAssertEqual(OptionalArgument("value"), .present("value"))
    }

    func testMapping() {
        XCTAssertEqual(
            OptionalArgument.present(1).map { $0 + 1 },
            .present(2)
        )
        XCTAssertEqual(
            OptionalArgument.absent().map { $0 + 1 },
            .absent()
        )
        XCTAssertEqual(
            OptionalArgument.null().map { $0 + 1 },
            .null()
        )
    }
}
