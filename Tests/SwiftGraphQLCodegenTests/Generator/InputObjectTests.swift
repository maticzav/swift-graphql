import XCTest
@testable import SwiftGraphQLCodegen


final class InputObjectTests: XCTestCase {
    let generator = GraphQLCodegen(options: GraphQLCodegen.Options())
    
    // MARK: - Tests
    
    func testEmptyInputObject() {
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: []
        )
        
        /* Tests */
        let expected = """
        struct InputObjectTest: Codable {
        }
        """
        
        XCTAssertEqual(
            generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    // MARK: - Docs
    
    func testFieldDocs() {
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .named(.scalar("ID"))
                ),
            ]
        )
        
        /* Tests */
        let expected = """
        struct InputObjectTest: Codable {
            /// Field description.
            let id: String?
        }
        """
        
        XCTAssertEqual(
            generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    // MARK: - Fields
    
    func testScalarField() {
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .named(.scalar("ID"))
                ),
            ]
        )
        
        /* Tests */
        let expected = """
        struct InputObjectTest: Codable {
            /// Field description.
            let id: String?
        }
        """
        
        XCTAssertEqual(
            generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    func testInputObjectField() {
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .named(.inputObject("AnotherInputObject"))
                ),
            ]
        )
        
        /* Tests */
        let expected = """
        struct InputObjectTest: Codable {
            /// Field description.
            let id: AnotherInputObject?
        }
        """
        
        XCTAssertEqual(
            generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    func testEnumField() {
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .named(.enum("ENUM"))
                ),
            ]
        )
        
        /* Tests */
        let expected = """
        struct InputObjectTest: Codable {
            /// Field description.
            let id: Enums.Enum?
        }
        """
        
        XCTAssertEqual(
            generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
}
