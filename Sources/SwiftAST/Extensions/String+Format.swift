import Foundation
import SwiftFormat

extension String {
    /// Formats the given Swift source code.
    func format() throws -> String {
        let formatted = try SwiftFormat.format(self)
        return formatted
    }
}
