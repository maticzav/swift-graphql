@testable import GraphQLAST
import XCTest

final class ASTSchemaTests: XCTestCase {
    func testSchemaObjects() {
        let schema = Schema(
            description: nil,
            types: [
                .object(ObjectType(name: "Object", description: nil, fields: [], interfaces: [])),
                .object(ObjectType(name: "__Object", description: nil, fields: [], interfaces: [])),
                .enum(EnumType(name: "Enum", description: nil, enumValues: [])),
            ],
            queryType: Operation(name: "RootQuery"),
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
        let schema = Schema(
            description: nil,
            types: [
                .object(ObjectType(name: "Object", description: nil, fields: [], interfaces: [])),
                .enum(EnumType(name: "__Enum", description: nil, enumValues: [])),
                .enum(EnumType(name: "Enum", description: nil, enumValues: [])),
            ],
            queryType: Operation(name: "RootQuery"),
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
        let schema = Schema(
            description: nil,
            types: [
                .inputObject(InputObjectType(name: "Input", description: nil, inputFields: [])),
                .inputObject(InputObjectType(name: "__Input", description: nil, inputFields: [])),
                .enum(EnumType(name: "__Enum", description: nil, enumValues: [])),
                .enum(EnumType(name: "Enum", description: nil, enumValues: [])),
            ],
            queryType: Operation(name: "RootQuery"),
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
        let schema = Schema(
            description: nil,
            types: [],
            queryType: Operation(name: "RootQuery"),
            mutationType: Operation(name: "RootMutation"),
            subscriptionType: nil
        )

        /* Tests */

        XCTAssertEqual(schema.operations, ["RootQuery", "RootMutation"])
    }
}
