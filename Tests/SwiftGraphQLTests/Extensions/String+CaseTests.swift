import XCTest
@testable import SwiftGraphQL

final class StringExtensionsTest: XCTestCase {
    func testCamelCase() {
        XCTAssertEqual("___a very peculiarNameIndeed__wouldNot.you.agree.AMAZING?____".camelCase, "aVeryPeculiarNameIndeedWouldNotYouAgreeAmazing")
        XCTAssertEqual("ENUM".camelCase, "enum")
        XCTAssertEqual("linkToURL".camelCase, "linkToUrl")
        XCTAssertEqual("grandfather_father.son grandson".camelCase, "grandfatherFatherSonGrandson")
    }
    
    func testPascalCase() {
        XCTAssertEqual("grandfather_father.son grandson".pascalCase, "GrandfatherFatherSonGrandson")
    }
}
