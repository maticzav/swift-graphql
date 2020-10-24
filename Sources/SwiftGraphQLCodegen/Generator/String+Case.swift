import Foundation


extension String {
    
    // MARK: - Public properties
    
    var pascalCase: String {
        self.words.map { $0.capitalized }.joined()
    }
    
    var camelCase: String {
        self[startIndex].lowercased() + self.pascalCase.dropFirst()
    }
    
    // MARK: - Internal interface
    
    /// Returns the words split either by special characters or trnsition from small charater to big one.
    private var words: [Substring] {
        guard !self.isEmpty else { return [] }
        
        var words = [Range<String.Index>]()
        
        var wordStart = self.startIndex
        var searchRange: Range<String.Index> = self.index(after: wordStart)..<self.endIndex
        
        /* Algorithm */
        while let upperCaseRange = self.rangeOfCharacter(from: <#T##CharacterSet#>)
        
        /* Result */
        let result = words.map { range in self[range] }
        return result
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
