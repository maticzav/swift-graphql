import Foundation

// MARK: - GraphQL Result

public struct GraphQLResult<Type, TypeLock> {
    public let data: Type
    public let errors: [GraphQLError]?
}

extension GraphQLResult: Equatable where Type: Equatable, TypeLock: Decodable {}

extension GraphQLResult where TypeLock: Decodable {
    init(_ response: Data, with selection: Selection<Type, TypeLock?>) throws {
        // Decodes the data using provided selection.
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(GraphQLResponse.self, from: response)
            self.data = try selection.decode(data: response.data)
            self.errors = response.errors
        } catch {
            // Catches all errors and turns them into a bad payload SwiftGraphQL error.
            throw HttpError.badpayload
        }
    }

    init(webSocketMessage: GraphQLSocketMessage, with selection: Selection<Type, TypeLock?>) throws {
        // Decodes the data using provided selection.
        do {
            let response: GraphQLResponse = try webSocketMessage.decodePayload()
            self.data = try selection.decode(data: response.data)
            self.errors = response.errors
        } catch {
            // Catches all errors and turns them into a bad payload SwiftGraphQL error.
            throw HttpError.badpayload
        }
    }

    // MARK: - Response

    struct GraphQLResponse: Decodable {
        let data: TypeLock?
        let errors: [GraphQLError]?
    }
}

// MARK: - GraphQL Error

public struct GraphQLError: Codable, Equatable {
    let message: String
    public let locations: [Location]?
//    public let path: [String]?

    public struct Location: Codable, Equatable {
        public let line: Int
        public let column: Int
    }
}
