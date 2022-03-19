@testable import SwiftGraphQLCodegen
import XCTest

final class StringExtensionsTest: XCTestCase {
    func testCamelCase() {
        XCTAssertEqual(".AGREE?_".camelCase, "agree")
        XCTAssertEqual("___a very peculiarName__wouldNot.you.AGREE?____".camelCase, "aVeryPeculiarNameWouldNotYouAgree")
        XCTAssertEqual("ENUM".camelCase, "enum")
        XCTAssertEqual("linkToURL".camelCase, "linkToUrl")
        XCTAssertEqual("grandfather_father.son grandson".camelCase, "grandfatherFatherSonGrandson")
        XCTAssertEqual("GRAndFATHER_Father.son".camelCase, "grAndFatherFatherSon")
        XCTAssertEqual("queryDBShortcuts".camelCase, "queryDbShortcuts")
    }

    func testPascalCase() {
        XCTAssertEqual("grandfather_father.son grandson".pascalCase, "GrandfatherFatherSonGrandson")
    }
}
