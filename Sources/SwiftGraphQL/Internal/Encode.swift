import Foundation

public struct Value {
    private let value: _Value

    // MARK: - Public interface
    
    /* Scalars */
    
    /// Encode nil.
    public static func `nil`() -> Value {
        Value(value: .nil)
    }
    
    /// Encode an integer.
    public static func int(_ int: Int) -> Value {
        Value(value: .int(int))
    }
    
    /// Encode a float.
    public static func float(_ float: Double) -> Value {
        Value(value: .float(float))
    }
    
    /// Encode a boolean.
    public static func bool(_ bool: Bool) -> Value {
        Value(value: .bool(bool))
    }
    
    /// Encode a string.
    public static func string(_ string: String) -> Value {
        Value(value: .string(string))
    }
    
    /* Enumerator */
    
    /// Encode an enumerator.
    public static func `enum`(_ enm: String) -> Value {
        Value(value: .enumValue(enm))
    }
    
    /* Wrappers */
    
    public static func list<T>(_ elements: [T], _ encoder: (T) -> Value) -> Value {
        Value(value: .list(elements.map(encoder)))
    }
    
    /* Serialize */
    
    
    /// Serializes a value into a string.
    func serialize() -> String {
        switch self.value {
        case .nil:
            return "null"
        /* Scalars */
        case .int(let int):
            return JSONEncoder().encodeJSON(int)
        case .float(let float):
            return JSONEncoder().encodeJSON(float)
        case .bool(let bool):
            return JSONEncoder().encodeJSON(bool)
        case .string(let string):
            return JSONEncoder().encodeJSON(string)
        /* Enumerators */
        case .enumValue(let enm):
            return enm
        /* Wrappers */
        case .list(let elements):
            return "[\(elements.map { $0.serialize() }.joined(separator: ", "))]"
        case .object(let dict):
            return "{ \(dict.map { "\($0.key): \($0.value.serialize())" }.joined(separator: ", ")) }"
        }
    }
    
    // MARK: - Private implementation
    
    private indirect enum _Value {
        case `nil`
        /* Scalar */
        case int(Int)
        case float(Double)
        case bool(Bool)
        case string(String)
        /* Enumerators */
        case enumValue(String)
        /* Wrappers */
        case list([Value])
        case object([String: Value])
    }
}

// MARK: - Public interface

extension JSONEncoder {
    fileprivate func encodeJSON<T: Encodable>(_ value: T) -> String {
        let data = try! self.encode(value)
        return String(data: data, encoding: .utf8)!
    }
}
