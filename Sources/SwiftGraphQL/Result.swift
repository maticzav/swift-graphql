import Foundation

// MARK: - GraphQL Result

public struct GraphQLResult<Type, TypeLock> {
    public let data: Type
    public let errors: [GraphQLError]?
    public let extensions: [String: AnyCodable]?
}

extension GraphQLResult: Equatable where Type: Equatable, TypeLock: Decodable {}

extension GraphQLResult where TypeLock: Decodable {
    init(_ response: Data, with selection: Selection<Type, TypeLock?>) throws {
        // Decodes the data using provided selection.
        var errors: [GraphQLError]? = nil
        var extensions: [String: AnyCodable]? = nil
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(GraphQLResponse.self, from: response)
            errors = response.errors
            extensions = response.extensions
            self.data = try selection.decode(data: response.data)
            self.errors = errors
            self.extensions = extensions
        } catch let error {
            // If we have specific errors, use them
            if let errors = errors, !errors.isEmpty {
                throw HttpError.graphQLErrors(errors, extensions: extensions)
            } else {
                throw HttpError.decodingError(error, extensions: extensions)
            }
        }
    }

    init(webSocketMessage: GraphQLSocketMessage, with selection: Selection<Type, TypeLock?>) throws {
        // Decodes the data using provided selection.
        do {
            let response: GraphQLResponse = try webSocketMessage.decodePayload()
            self.data = try selection.decode(data: response.data)
            self.errors = response.errors
            self.extensions = response.extensions
        } catch {
            // Catches all errors and turns them into a bad payload SwiftGraphQL error.
            throw HttpError.badpayload
        }
    }

    // MARK: - Response

    struct GraphQLResponse: Decodable {
        let data: TypeLock?
        let extensions: [String: AnyCodable]?
        let errors: [GraphQLError]?
    }
}

// MARK: - GraphQL Error

public struct GraphQLError: Codable, Equatable {
    public let message: String
    public let locations: [Location]?
    public let extensions: [String: AnyCodable]?

    public struct Location: Codable, Equatable {
        public let line: Int
        public let column: Int
    }
}
