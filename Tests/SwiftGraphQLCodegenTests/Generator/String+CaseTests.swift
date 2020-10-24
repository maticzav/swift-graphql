import XCTest
@testable import SwiftGraphQLCodegen

final class StringExtensionsTest: XCTestCase {
    func testCamelCase() {
        XCTAssertEqual("ENUM".camelCase, "enum")
        XCTAssertEqual("linkToURL".camelCase, "linkToUrl")
        XCTAssertEqual("grandfather_father.son grandson".camelCase, "grandfatherFatherSonGrandson")
    }
    
    func testPascalCase() {
        XCTAssertEqual("grandfather_father.son grandson".pascalCase, "GrandfatherFatherSonGrandson")
    }
}
