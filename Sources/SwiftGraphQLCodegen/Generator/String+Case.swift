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

