@testable import GraphQLAST
import XCTest

final class InvertedTypeRefTests: XCTestCase {
    func testInversion() {
        // [String]!
        let string = NamedType.scalar(ScalarType(name: "ID", description: nil))
        let typeRef = TypeRef.nonNull(.list(.list(.named(string))))
        let iTypeRef = InvertedTypeRef.list(.list(.nullable(.named(string))))

        XCTAssertEqual(typeRef.inverted.inverted, typeRef)
        XCTAssertEqual(iTypeRef.inverted.inverted, iTypeRef)
    }

    func testNullability() {
        let string = NamedType.scalar(ScalarType(name: "ID", description: nil))

        // String!

        XCTAssertEqual(
            TypeRef.nonNull(.named(string)).inverted,
            InvertedTypeRef.named(string)
        )
    }
}
