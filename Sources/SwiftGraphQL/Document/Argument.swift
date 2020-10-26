import Foundation

public struct Argument {
    var name: String
    var type: String
    var value: Data
}

// MARK: - Initializers

extension Argument {
    public init<T: Encodable>(name: String, type: String, value: T) {
        self.name = name
        self.type = type
        self.value = try! JSONEncoder().encode(value)
    }
}

// MARK: - Serialization Methods

extension Argument {
    // MARK: - Calculated properties
    
    // Returns the hash of the argument.
    var hash: String {
        String(self.value.hashValue, radix: 36).replacingOccurrences(of: "-", with: "_")
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
