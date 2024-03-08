@testable import SwiftGraphQL
import XCTest

final class StringExtensionsTest: XCTestCase {
    func testCamelCase() {
        XCTAssertEqual("___a very peculiarNameIndeed__wouldNot.you.agree.AMAZING?____".camelCasePreservingSurroundingUnderscores, "___aVeryPeculiarNameIndeedWouldNotYouAgreeAmazing____")
        XCTAssertEqual("ENUM".camelCasePreservingSurroundingUnderscores, "enum")
        XCTAssertEqual("linkToURL".camelCasePreservingSurroundingUnderscores, "linkToUrl")
        XCTAssertEqual("grandfather_father.son grandson".camelCasePreservingSurroundingUnderscores, "grandfatherFatherSonGrandson")
        XCTAssertEqual("queryDBShortcuts".camelCasePreservingSurroundingUnderscores, "queryDbShortcuts")
    }

    func testPascalCase() {
        XCTAssertEqual("grandfather_father.son grandson".pascalCase, "GrandfatherFatherSonGrandson")
    }
}
