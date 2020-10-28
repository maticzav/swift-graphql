import Foundation

public struct Argument {
    var name: String
    var type: String
    var value: NSObject
}

extension Argument {
    public init<T: Encodable & Hashable>(name: String, type: String, value: T) {
        self.name = name
        self.type = type
        
        /* Encode value */
        self.value = try! VariableEncoder().encode(value)
    }
}

extension Argument {
    // MARK: - Calculated properties
    
    // Returns the hash of the argument.
    var hash: String {
        let hash = String(self.value.hashValue, radix: 36)
        let normalized = hash.replacingOccurrences(of: "-", with: "_")
        return "_\(normalized)"
    }
}
