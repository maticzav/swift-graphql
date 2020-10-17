import XCTest
@testable import SwiftGraphQLCodegen

final class StringExtensionsTest: XCTestCase {
    func testCamelCase() {
        XCTAssertEqual("grandfather_father.son grandson".camelCase, "grandfatherFatherSonGrandson")
    }
    
    func testPascalCase() {
        XCTAssertEqual("grandfather_father.son grandson".pascalCase, "GrandfatherFatherSonGrandson")
    }
    
    func testLines() {
        XCTAssertEqual(["A", "B", "C"].lines, "A\nB\nC")
    }
}
