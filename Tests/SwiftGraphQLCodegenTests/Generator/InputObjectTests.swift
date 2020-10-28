import XCTest
@testable import SwiftGraphQLCodegen


final class InputObjectTests: XCTestCase {
    let generator = GraphQLCodegen(options: GraphQLCodegen.Options())
    
    // MARK: - Tests
    
    func testEmptyInputObject() throws {
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: []
        )
        
        /* Tests */
        let expected = """
        struct InputObjectTest: Codable, Hashable {
        }
        """
        
        XCTAssertEqual(
            try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    // MARK: - Docs
    
    func testFieldDocs() throws {
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
        struct InputObjectTest: Codable, Hashable {
            /// Field description.
            let id: String?
        }
        """
        
        XCTAssertEqual(
            try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    // MARK: - Fields
    
    func testScalarField() throws {
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
        struct InputObjectTest: Codable, Hashable {
            /// Field description.
            let id: String?
        }
        """
        
        XCTAssertEqual(
            try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    func testInputObjectField() throws {
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
        struct InputObjectTest: Codable, Hashable {
            /// Field description.
            let id: AnotherInputObject?
        }
        """
        
        XCTAssertEqual(
            try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    func testEnumField() throws {
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
        struct InputObjectTest: Codable, Hashable {
            /// Field description.
            let id: Enums.Enum?
        }
        """
        
        XCTAssertEqual(
            try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
}
