import XCTest
@testable import SwiftGraphQLCodegen


final class InputObjectTests: XCTestCase {
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
            GraphQLCodegen.generateInputObject("InputObjectTest", for: type),
            expected
        )
    }
    
    // MARK: - Fields
    
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
            GraphQLCodegen.generateInputObject("InputObjectTest", for: type),
            expected
        )
    }
    
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
            GraphQLCodegen.generateInputObject("InputObjectTest", for: type),
            expected
        )
    }
}


                
//                /* Scalar, default value */
//                GraphQL.InputValue(
//                    name: "int",
//                    description: nil,
//                    type: .named(.scalar(.integer)),
//                    defaultValue: "15"
//                ),
