import Foundation

public struct Argument {
    var name: String
    var type: String
    var value: NSObject
}



// MARK: - Initializers

extension Argument {
    public init<T: Encodable & Hashable>(name: String, type: String, value: T) {
        self.name = name
        self.type = type
        
        /* Encode value */
        self.value = try! VariableEncoder().encode(value)
    }
}

// MARK: - Serialization Methods

extension Argument {
    // MARK: - Calculated properties
    
    // Returns the hash of the argument.
    var hash: String {
        let hash = String(self.value.hashValue, radix: 36)
        let normalized = hash.replacingOccurrences(of: "-", with: "_")
        return "_\(normalized)"
    }
    
    // MARK: - Methods
    
    /// Serializes a single argument into query.
    func serialize() -> String {
        "\(self.name): $\(self.hash)"
    }
}

extension Collection {
    /// Serializes a collection of arguments into a query string.
    func serialize() -> String where Element == Argument {
        /* Return empty string for no arguments. */
        if self.isEmpty {
            return ""
        }
        return "(\(self.map { $0.serialize() }.joined(separator: ", ")))"
        
    }
}
