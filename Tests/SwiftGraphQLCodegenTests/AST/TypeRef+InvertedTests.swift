import XCTest
@testable import SwiftGraphQLCodegen

final class InvertedTypeRefTests: XCTestCase {
    func testInversion() {
        // [String]!
        let string = GraphQL.NamedType.scalar(GraphQL.ScalarType(name: "ID", description: nil))
        let typeRef = GraphQL.TypeRef.nonNull(.list(.list(.named(string))))
        let iTypeRef = GraphQL.InvertedTypeRef.list(.list(.nullable(.named(string))))
        
        XCTAssertEqual(typeRef.inverted.inverted, typeRef)
        XCTAssertEqual(iTypeRef.inverted.inverted, iTypeRef)
    }
    
    func testNullability() {
        let string = GraphQL.NamedType.scalar(GraphQL.ScalarType(name: "ID", description: nil))
        
        // String!
        
        XCTAssertEqual(
            GraphQL.TypeRef.nonNull(.named(string)).inverted,
            GraphQL.InvertedTypeRef.named(string)
        )
    }
}
