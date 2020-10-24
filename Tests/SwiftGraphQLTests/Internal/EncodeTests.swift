import XCTest
@testable import SwiftGraphQL

final class EncodeTests: XCTestCase {
    // MARK: - Scalars
    func testScalars() throws {
        test("Matic", equals: "\"Matic\"")
        test(92, equals: "92")
        test(true, equals: "true")
    }
    
    // MARK: - List
    func testEncodeLists() throws {
        test([ "Matic", "Ema", "Jan" ], equals: #"[ "Matic", "Ema", "Jan" ]"#)
    }
    
    func testNestedLists() {
        let value = [["apple"], ["banana"]]
        test(value, equals: #"[["apple"], ["banana"]]"#)
    }
    
    // MARK: - Objects
    func testObjects() throws {
        struct Person: Encodable {
            let name: String
            let age: Int
        }
        
        test(Person(name: "Matic", age: 20), equals: #"{ age: 20, name: "Matic" }"#)
    }
    
    func testNestedObjects() throws {
        struct Person: Encodable {
            let name: String
            let age: Int
            let address: Address
        }
        
        struct Address: Encodable {
            let city: String
            let street: String
        }
        
        let value = Person(
            name: "Matic",
            age: 20,
            address: Address(city: "SF", street: "Menlo Park")
        )
        test(value, equals: #"{ name: "Matic", age: 20, address: { city: "SF", street: "Menlo Park" } }"#)
    }
    
    // MARK: - Private helpers
    
    let encoder = GQLEncoder()
    
    func test<T: Encodable>(_ value: T, equals expected: String) {
        XCTAssertEqual(try encoder.encode(value), expected)
    }
}
