import XCTest
@testable import SwiftGraphQL

final class OptionalArgumentTests: XCTestCase {
    func testFromMaybe() {
        XCTAssertEqual(OptionalArgument<String>(optional: nil), .absent)
        XCTAssertEqual(OptionalArgument(optional: "value"), .present("value"))
    }
    
    func testMapping() {
        XCTAssertEqual(
            OptionalArgument.present(1).map { $0 + 1 },
            .present(2)
        )
        XCTAssertEqual(
            OptionalArgument.absent.map { $0 + 1 },
            .absent
        )
        XCTAssertEqual(
            OptionalArgument.null.map { $0 + 1 },
            .null
        )
    }
    
    func testEncoding() throws {
        
        /* Data */
        struct Input: Encodable {
            let name: String
            let surname: OptionalArgument<String>
        }
        
        let data = Input(name: "Matic", surname: .absent)
        
        /* Tests */
        let encoder = JSONEncoder()
        let value = try encoder.encode(data)
        let expected = #"{"name":"Matic"}"#
        
        XCTAssertEqual(String(data: value, encoding: .utf8), expected)
    }
}
