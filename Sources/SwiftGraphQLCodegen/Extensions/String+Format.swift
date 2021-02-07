import Foundation
import SwiftFormat

extension String {
    /// Formats the given Swift source code.
    func format() throws -> String {
        let trimmed = trimmingCharacters(
            in: CharacterSet.newlines.union(.whitespaces)
        )
        let formatted = try SwiftFormat.format(trimmed)
        return formatted
    }
}
