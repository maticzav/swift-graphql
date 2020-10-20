import Foundation


extension String {
    
    // MARK: - Public properties
    
    var pascalCase : String {
        self.words.map { $0.capitalized }.joined()
    }
    
    var camelCase : String {
        self[startIndex].lowercased() + self.pascalCase.dropFirst(1)
    }
    
    // MARK: - Internal interface
    
    private var words: [String] {
        let separators = CharacterSet(charactersIn: ",;-_() .")
        let words = self.components(separatedBy: separators)
        return words.compactMap { $0.trimmed.nonEmpty }
    }
    
    private var nonEmpty: String? {
        self == "" ? nil : self
    }
    
    private var trimmed: String {
        self.trimmingCharacters(in: CharacterSet(charactersIn: " "))
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
    /* Keywords used in patterns */
    "_"
    // NOTE: There are other reserved keywords, but they aren't important in context.
]
