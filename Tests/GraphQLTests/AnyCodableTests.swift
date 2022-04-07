import Foundation
@testable import GraphQL
import XCTest

final class AnyCodableTests: XCTestCase {
    
    func testAnyCodableToOptional() throws {
        XCTAssertEqual(Optional(AnyCodable(())), nil)
        XCTAssertEqual(Optional(AnyCodable(1)), 1)
    }
}
