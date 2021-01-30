import Foundation
import SwiftSyntax
import SwiftFormat
import SwiftFormatConfiguration

extension String {
    /// Formats the given Swift source code.
    func format() throws -> String {
        let source = try SyntaxParser.parse(source: self)
        var formatted = ""
        
        let formatter = SwiftFormatter(configuration: Configuration())
        try formatter.format(syntax: source, assumingFileURL: nil, to: &formatted)
        
        return formatted
    }
}
