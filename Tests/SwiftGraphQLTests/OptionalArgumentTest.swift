import XCTest
@testable import SwiftGraphQL

final class OptionalArgumentTests: XCTestCase {
    func testFromMaybe() {
        XCTAssertEqual(OptionalArgument<String>(optional: nil), .absent)
        XCTAssertEqual(OptionalArgument(optional: "value"), .present("value"))
    }
    
    func testMapping() {
        XCTAssertEqual(
            OptionalArgument.present(1).map { $0 + 1 },
            .present(2)
        )
        XCTAssertEqual(
            OptionalArgument.absent.map { $0 + 1 },
            .absent
        )
        XCTAssertEqual(
            OptionalArgument.null.map { $0 + 1 },
            .null
        )
    }
}
