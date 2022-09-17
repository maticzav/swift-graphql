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
        
        let blanks = CharacterSet.newlines.union(CharacterSet.whitespaces)
        return output.trimmingCharacters(in: blanks)
    }
    
    /// Adds backticks on reserved words.
    ///
    /// - NOTE: Function arguments don't need to be normalized.
    var normalize: String {
        if reservedWords.contains(self) {
            return "`\(self)`"
        }
        return self
    }
}

// https://docs.swift.org/swift-book/ReferenceManual/LexicalStructure.html
let reservedWords = [
    /* Keywords used in delcarations. */
    "associatedtype",
    "class",
    "deinit",
    "enum",
    "extension",
    "fileprivate",
    "func",
    "import",
    "init",
    "inout",
    "internal",
    "let",
    "open",
    "operator",
    "private",
    "protocol",
    "public",
    "rethrows",
    "static",
    "struct",
    "subscript",
    "typealias",
    "var",
    /* Keywords used in statements */
    "break",
    "case",
    "continue",
    "default",
    "defer",
    "do",
    "else",
    "fallthrough",
    "for",
    "guard",
    "if",
    "in",
    "repeat",
    "return",
    "switch",
    "where",
    "while",
    /* Keywords used in expressions and types */
    "as",
    "Any",
    "catch",
    "false",
    "is",
    "nil",
    "super",
    "self",
    "Self",
    "throw",
    "throws",
    "true",
    "try",
    /* Booleans */
    "not",
    "and",
    "or",
    /* Keywords used in patterns */
    "_",
    // NOTE: There are other reserved keywords, but they aren't important in this context.
]


extension Collection where Element == String {
    
    /// Returns a string showing each string in new line.
    var lines: String {
        joined(separator: "\n")
    }
}
