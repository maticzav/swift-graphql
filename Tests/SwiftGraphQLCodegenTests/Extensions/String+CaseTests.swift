@testable import SwiftGraphQL
import XCTest

final class StringExtensionsTest: XCTestCase {
    func testCamelCase() {
        XCTAssertEqual("___a very peculiarNameIndeed__wouldNot.you.agree.AMAZING?____".camelCase, "aVeryPeculiarNameIndeedWouldNotYouAgreeAmazing")
        XCTAssertEqual("ENUM".camelCase, "enum")
        XCTAssertEqual("linkToURL".camelCase, "linkToUrl")
        XCTAssertEqual("grandfather_father.son grandson".camelCase, "grandfatherFatherSonGrandson")
        XCTAssertEqual("GRAndFATHER_Father.son".camelCase, "grAndFatherFatherSon")
    }

    func testPascalCase() {
        XCTAssertEqual("grandfather_father.son grandson".pascalCase, "GrandfatherFatherSonGrandson")
    }
}
