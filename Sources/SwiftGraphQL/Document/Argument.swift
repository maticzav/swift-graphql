import Foundation

public struct Argument {
    var name: String
    var value: Value
}

// MARK: - Methods

extension Argument {
    /// Serializes a single argument into query.
    func serialize() -> String {
        "\(self.name): \(self.value.serialize())"
    }
}

extension Collection where Element == Argument {
    
    /// Serializes a collection of arguments into a query string.
    func serialize() -> String {
        /* Return empty string for no arguments. */
        guard self.count > 0 else {
            return ""
        }
        
        /* Parse each argument individually otherwise. */
        return "(\(self.map { $0.serialize() }.joined(separator: ", ")))"
    }
}
