import XCTest
@testable import SwiftGraphQLCodegen

final class ASTSchemaTests: XCTestCase {
    func testSchemaObjects() {
        let schema = GraphQL.Schema(
            description: nil,
            types: [
                .object(GraphQL.ObjectType(name: "Object", description: nil, fields: [], interfaces: [])),
                .object(GraphQL.ObjectType(name: "__Object",description: nil,fields: [],interfaces: [])),
                .enum(GraphQL.EnumType(name: "Enum", description: nil, enumValues: []))
            ],
            queryType: GraphQL.Operation(name: "RootQuery"),
            mutationType: nil,
            subscriptionType: nil
        )
        
        /* Tests */
        
        XCTAssertEqual(
            schema.objects.map { $0.name },
            ["Object"]
        )
    }

    func testSchemaEnums() {
        let schema = GraphQL.Schema(
            description: nil,
            types: [
                .object(GraphQL.ObjectType(name: "Object", description: nil, fields: [], interfaces: [])),
                .enum(GraphQL.EnumType(name: "__Enum", description: nil, enumValues: [])),
                .enum(GraphQL.EnumType(name: "Enum", description: nil, enumValues: []))
            ],
            queryType: GraphQL.Operation(name: "RootQuery"),
            mutationType: nil,
            subscriptionType: nil
        )
        
        /* Tests */
        
        XCTAssertEqual(
            schema.enums.map { $0.name },
            ["Enum"]
        )
    }
    
    func testSchemaInputObjects() {
        let schema = GraphQL.Schema(
            description: nil,
            types: [
                .inputObject(GraphQL.InputObjectType(name: "Input", description: nil, inputFields: [])),
                .inputObject(GraphQL.InputObjectType(name: "__Input", description: nil, inputFields: [])),
                .enum(GraphQL.EnumType(name: "__Enum", description: nil, enumValues: [])),
                .enum(GraphQL.EnumType(name: "Enum", description: nil, enumValues: []))
            ],
            queryType: GraphQL.Operation(name: "RootQuery"),
            mutationType: nil,
            subscriptionType: nil
        )
        
        /* Tests */
        
        XCTAssertEqual(
            schema.inputObjects.map { $0.name },
            ["Input"]
        )
    }
    
    func testSchemaOperations() {
        let schema = GraphQL.Schema(
            description: nil,
            types: [],
            queryType: GraphQL.Operation(name: "RootQuery"),
            mutationType: GraphQL.Operation(name: "RootMutation"),
            subscriptionType: nil
        )
        
        /* Tests */
        
        XCTAssertEqual(schema.operations, ["RootQuery", "RootMutation"])
    }
}
