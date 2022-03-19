import Foundation
import SwiftFormat
import SwiftFormatConfiguration

extension String {
    /// Formats the given Swift source code.
    ///
    /// - NOTE: Make sure your Swift version (i..e `swift --version`, matches the toolchain
    ///         version of Swift Format. Read more about it at https://github.com/apple/swift-format#matching-swift-format-to-your-swift-version.
    func format() throws -> String {
        let trimmed = trimmingCharacters(
            in: CharacterSet.newlines.union(.whitespaces)
        )
        
        let formatter = SwiftFormatter(configuration: Configuration())
        
        var output = ""
        
        do {
            try formatter.format(source: trimmed, assumingFileURL: nil, to: &output)
        } catch(let err) {
            throw CodegenError.formatting(err)
        }
        
        return output
    }
}
