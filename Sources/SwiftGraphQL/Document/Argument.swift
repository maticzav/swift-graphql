import Foundation

public struct Argument {
    var name: String
    var value: String
}

extension Argument {
    public init<T: Encodable>(name: String, value: T) {
        self.name = name
        self.value = try! GQLEncoder().encode(value)
    }
}

// MARK: - Serialization Methods

extension Argument {
    // MARK: - Methods
    
    /// Serializes a single argument into query.
    func serialize() -> String {
        "\(self.name): \(self.value)"
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
