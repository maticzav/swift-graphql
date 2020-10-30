import Foundation

public struct Argument: Hashable {
    let name: String
    let type: String
    let hash: String
    let value: NSObject
}

extension Argument {
    public init<T: Encodable & Hashable>(name: String, type: String, value: T) {
        self.name = name
        self.type = type
        self.hash = hashInt(value.hashValue)
        
        /* Encode value */
        self.value = try! VariableEncoder().encode(value)
    }
}

// MARK: - Hashing

extension Array where Element == Argument {
    // Returns the hash of the collection of arguments.
    var hash: String {
        hashInt(self.hashValue)
    }
}

/// Returns the string representation of the int hash.
private func hashInt(_ value: Int) -> String {
    let hash = String(value, radix: 36)
    let normalized = hash.replacingOccurrences(of: "-", with: "_")
    return "_\(normalized)"
}
