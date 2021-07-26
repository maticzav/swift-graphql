import Foundation

// MARK: - GraphQL Execution Result

public struct GraphQLResult<Type> {
    public let data: Type
    public let errors: [GraphQLError]?
}

public struct GraphQLError: Codable, Equatable {
    public let message: String
    public let locations: [Location]?
//    public let path: [String]?

    public struct Location: Codable, Equatable {
        public let line: Int
        public let column: Int
    }
}


// MARK: - Extensions

extension GraphQLResult: Encodable where Type: Encodable {}
extension GraphQLResult: Decodable where Type: Decodable {}
extension GraphQLResult: Equatable where Type: Equatable {}
