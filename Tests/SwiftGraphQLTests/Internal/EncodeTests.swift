import XCTest
@testable import SwiftGraphQL

final class EncodeTests: XCTestCase {
    // MARK: - Scalars
    func testEncodeScalars() throws {
        test("Matic", equals: "\"Matic\"")
        test(92, equals: "92")
        test(true, equals: "true")
    }
    
    // MARK: - List
    func testEncodeLists() throws {
        test([ "Matic", "Ema", "Jan" ], equals: #"[ \"Matic\", \"Ema\", \"Jan\" ]"#)
    }
    
    // MARK: - Objects
    func testEncodeObjects() throws {
        struct Person: Encodable {
            let name: String
            let age: Int
        }
        
        test(Person(name: "Matic", age: 20), equals: #"{ name: "Matic", age: 20 }"#)
    }
    
    // MARK: - Private helpers
    
    let encoder = GQLEncoder()
    
    func test<T: Encodable>(_ value: T, equals expected: String) {
        XCTAssertEqual(try encoder.encode(value), expected)
    }
}
