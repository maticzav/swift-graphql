import Foundation

public struct Argument {
    var name: String
    var value: Data
    
    init(name: String, value: Data) {
        self.name = name
        self.value = value
    }
}

extension Argument {
    public init<Value: Encodable>(name: String, value: Value) {
        self.name = name
        self.value = try! JSONEncoder().encode(value)
    }
}

// MARK: - Serialization Methods

extension Argument {
    /// Serializes a single argument into query.
    func serialize() -> String {
        "\(self.name): \(String(data: self.value, encoding: .utf8)!)"
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
