import Foundation

extension String {
    /// Adds backticks on reserved words.
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
    // NOTE: There are other reserved keywords, but they aren't important in context.
]
