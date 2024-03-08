import GraphQL
import SwiftGraphQLClient
import XCTest
import RxSwift
import SwiftGraphQL

final class AsyncInterfaceTests: XCTestCase {
    func testAsyncSelectionQueryReturnsValue() async throws {
        let selection = Selection<String, Objects.User> {
            try $0.id()
        }

        let client = MockClient(customExecute: { operation in
            let id = GraphQLField.leaf(field: "id", parent: "User", arguments: [])

            let user = GraphQLField.composite(
                field: "user",
                parent: "Query",
                type: "User",
                arguments: [],
                selection: selection.__selection()
            )

            let result = OperationResult(
                operation: operation,
                data: [
                    user.alias!: [
                        id.alias!: "123"
                    ]
                ],
                error: nil
            )
            return Observable.just(result)
        })


        let result = try await client.query(Objects.Query.user(selection: selection))
        XCTAssertEqual(result.data, "123")
    }

    func testAsyncSelectionQueryThrowsError() async throws {
        let selection = Selection<String, Objects.User> {
            try $0.id()
        }

        let client = MockClient(customExecute: { operation in
            let result = OperationResult(
                operation: operation,
                data: ["unknown_field": "123"],
                error: nil
            )
            return Observable.just(result)
        })

        await XCTAssertThrowsError(of: ObjectDecodingError.self) {
            try await client.query(Objects.Query.user(selection: selection))
        }
    }

    func testAsyncSelectionMutationReturnsValue() async throws {
        let selection = Selection.AuthPayload<String?> {
            try $0.on(
                authPayloadSuccess: Selection.AuthPayloadSuccess<String?> {
                    try $0.token()
                },
                authPayloadFailure: Selection.AuthPayloadFailure<String?> { _ in
                    nil
                }
            )
        }

        let client = MockClient(customExecute: { operation in
            let token = GraphQLField.leaf(field: "token", parent: "AuthPayloadSuccess", arguments: [])

            let auth = GraphQLField.composite(
                field: "auth",
                parent: "Mutation",
                type: "AuthPayload",
                arguments: [],
                selection: selection.__selection()
            )

            let result = OperationResult(
                operation: operation,
                data: [
                    auth.alias!: [
                        "__typename": "AuthPayloadSuccess",
                        token.alias!: "123"
                    ]
                ],
                error: nil
            )
            return Observable.just(result)
        })

        let result = try await client.mutate(Objects.Mutation.auth(selection: selection))
        XCTAssertEqual(result.data, "123")
    }

    func testAsyncSelectionMutationThrowsError() async throws {
        let selection = Selection.AuthPayload<String?> {
            try $0.on(
                authPayloadSuccess: Selection.AuthPayloadSuccess<String?> {
                    try $0.token()
                },
                authPayloadFailure: Selection.AuthPayloadFailure<String?> { _ in
                    nil
                }
            )
        }

        let client = MockClient(customExecute: { operation in
            let result = OperationResult(
                operation: operation,
                data: ["unknown_field": "123"],
                error: nil
            )
            return Observable.just(result)
        })

        await XCTAssertThrowsError(of: ObjectDecodingError.self) {
            try await client.mutate(Objects.Mutation.auth(selection: selection))
        }
    }
}
