import Foundation
import GraphQL
import SwiftGraphQL

extension Date: GraphQLScalar {
    public init(from codable: AnyCodable) throws {
        guard let raw = codable.value as? String else {
            throw DateTimeScalarDecodingError.invalidType
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: raw) else {
            throw DateTimeScalarDecodingError.invalidValue
        }
        
        self = date
    }
    
    public static var mockValue = Date.now
}

enum DateTimeScalarDecodingError: Error {
    case invalidType
    case invalidValue
}
