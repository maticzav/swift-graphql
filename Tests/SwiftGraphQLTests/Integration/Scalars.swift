import GraphQL
import Foundation
import SwiftGraphQL

extension Date: GraphQLScalar {
    public init(from codable: AnyCodable) throws {
        switch codable.value {
            case let value as String:
                let dateFormatter = DateFormatter()

                dateFormatter.calendar = Calendar(identifier: .iso8601)
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

                if let date = dateFormatter.date(from: value) {
                    self = date
                } else {
                    throw DateFormattingError.couldNotParse
                }
            default:
                throw DateFormattingError.unexpectedType
        }
    }

    public static var mockValue: Date {
        Date(timeIntervalSince1970: 0)
    }
}

enum DateFormattingError: Error {

    /// Could not parse the error from the string.
    case couldNotParse

    /// Expected a string but got a different scalar.
    case unexpectedType
}
