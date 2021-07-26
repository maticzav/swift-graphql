import Foundation


// Based on: https://github.com/yonaskolb/Codability/blob/master/Sources/Codability/AnyCodable.swift
// which is based on: https://github.com/Flight-School/AnyCodable

// Updated to allow AnyCodable to be initialised using any Encodable type rather than just the hardcoded JSON types

// MARK: - AnyCodable

/**
 A type-erased `Codable` value.
 
 You can encode or decode mixed-type or unknown values in dictionaries
 and other collections that require `Encodable` or `Decodable` conformance
 by declaring their contained type to be `AnyCodable`.
 */
public struct AnyCodable {
    public let value: Any
    
    public init<T>(_ value: T?) {
        if let preventNesting = value as? AnyCodable {
            self = preventNesting
        } else if let value = value.flattened() {
            self.value = value
        } else {
            self.value = ()
        }
    }
}

extension AnyCodable: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self.value {
        case let encodable as Encodable:
            try encodable.encode(to: encoder)
        case is Void:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        case let array as [Any?]:
            var container = encoder.singleValueContainer()
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any?]:
            var container = encoder.singleValueContainer()
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(self.value, context)
        }
    }
}

extension AnyCodable: Equatable {
    /// If you initialised AnyCodable using a custom Encodable object you can't compare them.
    /// If you NEED to compare them call `recode()` on both AnyCodables.
    public static func ==(lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (Void, Void):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            return lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            return lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            return lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            return lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            return lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            return lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            return lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            return lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            return lhs == rhs
        case let (lhs as Float, rhs as Float):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case (let lhs as [String: AnyCodable], let rhs as [String: AnyCodable]):
            return lhs == rhs
        case (let lhs as [AnyCodable], let rhs as [AnyCodable]):
            return lhs == rhs
        default:
            return false
        }
    }
    
    /// If you initialised AnyCodable with a custom Encodable type this will decode that into
    /// an AnyCodable built out of the core json types (bool, number, string, array, dictionary).
    ///
    /// Calling this allows you to compare AnyCodables that were initialised with a custom Encodable type.
    mutating func recode() throws {
        let encoded = try JSONEncoder().encode(self)
        self = try JSONDecoder().decode(AnyCodable.self, from: encoded)
    }
}

extension AnyCodable: CustomStringConvertible {
    public var description: String {
        switch value {
        case is Void:
            return String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}

extension AnyCodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "AnyCodable(\(value.debugDescription))"
        default:
            return "AnyCodable(\(self.description))"
        }
    }
}

extension AnyCodable: ExpressibleByNilLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {

    public init(nilLiteral: ()) {
        self.init(nil as Any?)
    }

    public init(booleanLiteral value: Bool) {
        self.init(value)
    }

    public init(integerLiteral value: Int) {
        self.init(value)
    }

    public init(floatLiteral value: Double) {
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }

    public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
        self.init(Dictionary<AnyHashable, Any>(elements, uniquingKeysWith: { (first, _) in first }))
    }
}

// MARK: - Flattenable Protocol

protocol Flattenable {
  func flattened() -> Any?
}

extension Optional: Flattenable {
  func flattened() -> Any? {
    switch self {
    case .some(let x as Flattenable): return x.flattened()
    case .some(let x): return x
    case .none: return nil
    }
  }
}
