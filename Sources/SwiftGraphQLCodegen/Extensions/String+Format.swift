import Foundation
import SwiftFormat
import SwiftFormatConfiguration

extension String {
    /// Formats the given Swift source code.
    func format() throws -> String {
        let trimmed = trimmingCharacters(
            in: CharacterSet.newlines.union(.whitespaces)
        )
        
        let formatter = SwiftFormatter(configuration: Configuration())
        
        var output = ""
        try formatter.format(source: trimmed, assumingFileURL: nil, to: &output)
        
        return output
    }
}
