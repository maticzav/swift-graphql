import Foundation
import GraphQL
import SwiftGraphQL

// https://docs.github.com/en/graphql/reference/scalars#base64string
extension URL: GraphQLScalar {
    public init(from codable: AnyCodable) throws {
        guard let raw = codable.value as? String, let url = URL(string: raw) else {
            throw URLDecodingError.invalidURL
        }
        self = url
    }
    
    public static var mockValue = URL(string: "https://swift-graphql.com")!
}

enum URLDecodingError: Error {
    case invalidURL
}
