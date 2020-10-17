import Foundation


extension String {
    var pascalCase : String {
        self.words.map { $0.capitalized }.joined()
    }
    
    var camelCase : String {
        self[startIndex].lowercased() + self.pascalCase.dropFirst(1)
    }
    
    var words: [String] {
        let separators = CharacterSet(charactersIn: ",;-_() .")
        let words = self.components(separatedBy: separators)
        return words.compactMap { $0.trimmed.nonEmpty }
    }
    
    var nonEmpty: String? {
        self == "" ? nil : self
    }
    
    var trimmed: String {
        self.trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
}

extension Collection where Element == String {
    var lines: String {
        self.joined(separator: "\n")
    }
}



