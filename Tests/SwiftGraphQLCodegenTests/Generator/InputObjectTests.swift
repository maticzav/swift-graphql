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
        struct InputObjectTest: Encodable, Hashable {

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
            
            }

            /* CodingKeys */
            enum CodingKeys: CodingKey {
            }
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
        struct InputObjectTest: Encodable, Hashable {
            /// Field description.
            var id: OptionalArgument<String> = .absent

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
            
                if id.hasValue { try container.encode(id, forKey: .id) }
            }

            /* CodingKeys */
            enum CodingKeys: CodingKey {
                case id
            }
        }
        """
        
        XCTAssertEqual(
            try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    // MARK: - Fields
    
    func testOptionalField() throws {
        
        /* Type */
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
        struct InputObjectTest: Encodable, Hashable {
            /// Field description.
            var id: OptionalArgument<String> = .absent

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
            
                if id.hasValue { try container.encode(id, forKey: .id) }
            }

            /* CodingKeys */
            enum CodingKeys: CodingKey {
                case id
            }
        }
        """
        
        XCTAssertEqual(
            try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    func testScalarField() throws {
        
        /* Type */
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .nonNull(.named(.scalar("ID")))
                ),
            ]
        )
        
        /* Tests */
        let expected = """
        struct InputObjectTest: Encodable, Hashable {
            /// Field description.
            var id: String

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
            
                try container.encode(id, forKey: .id)
            }

            /* CodingKeys */
            enum CodingKeys: CodingKey {
                case id
            }
        }
        """
        
        XCTAssertEqual(
            try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    func testInputObjectField() throws {
        
        /* Type */
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .nonNull(.named(.inputObject("AnotherInputObject")))
                ),
            ]
        )
        
        /* Tests */
        let expected = """
        struct InputObjectTest: Encodable, Hashable {
            /// Field description.
            var id: InputObjects.AnotherInputObject

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
            
                try container.encode(id, forKey: .id)
            }

            /* CodingKeys */
            enum CodingKeys: CodingKey {
                case id
            }
        }
        """
        
        XCTAssertEqual(
            try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
    
    func testEnumField() throws {
        
        /* Type */
        let type = GraphQL.InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                GraphQL.InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .nonNull(.named(.enum("ENUM")))
                ),
            ]
        )
        
        /* Tests */
        let expected = """
        struct InputObjectTest: Encodable, Hashable {
            /// Field description.
            var id: Enums.Enum

            /* Encoder */
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
            
                try container.encode(id, forKey: .id)
            }

            /* CodingKeys */
            enum CodingKeys: CodingKey {
                case id
            }
        }
        """
        
        XCTAssertEqual(
            try generator.generateInputObject("InputObjectTest", for: type).joined(separator: "\n"),
            expected
        )
    }
}
