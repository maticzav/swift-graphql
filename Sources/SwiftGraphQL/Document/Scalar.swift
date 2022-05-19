import Foundation
import GraphQL

/// Protocol that a custom scalar should implement to be used with SwiftGraphQL.
public protocol GraphQLScalar: Encodable {
    
    /// A decoder from the any-type codable value.
    init(from: AnyCodable) throws
    
    /// Provides a default value used to mock in SwiftGraphQL selection set.
    ///
    /// - NOTE: This value is used by the generated functions, it can be of any value conforming to your type.
    static var mockValue: Self { get }
}

// MARK: - Composition

extension Array: GraphQLScalar where Element: GraphQLScalar {
    public init(from codable: AnyCodable) throws {
        switch(codable.value) {
        case let value as [AnyCodable]:
            self = try value.map { try Element(from: $0) }
        default:
            let err = ScalarDecodingError.unexpectedScalarType(
                expected: "Collection",
                received: codable.value
            )
            throw err
        }
    }
    
    public static var mockValue: [Element] { [] }
}

extension Optional: GraphQLScalar where Wrapped: GraphQLScalar {
    public init(from codable: AnyCodable) throws {
        
        switch(codable.value) {
        #if canImport(Foundation)
        case is NSNull:
            self = nil
        #endif
        case is Void, nil:
            self = nil
        case Optional<AnyDecodable>.none:
            self = nil
        default:
            self = try Wrapped(from: codable)
        }
    }
    
    public static var mockValue: Wrapped? { nil }
}

// MARK: - Built-In Types

extension String: GraphQLScalar {
    public init(from codable: AnyCodable) throws {
        switch(codable.value) {
        case let string as String:
            self = string
        default:
            let err = ScalarDecodingError.unexpectedScalarType(
                expected: "String",
                received: codable.value
            )
            throw err
        }
    }
    
    public static let mockValue = "<mock>"
}

extension Int: GraphQLScalar {
    public init(from codable: AnyCodable) throws {
        switch(codable.value) {
        case let value as Int:
            self = value
        case let value as Int8:
            self = Int(value)
        case let value as Int16:
            self = Int(value)
        case let value as Int32:
            self = Int(value)
        case let value as Int64:
            self = Int(value)
        case let value as UInt:
            self = Int(value)
        case let value as UInt8:
            self = Int(value)
        case let value as UInt16:
            self = Int(value)
        case let value as UInt32:
            self = Int(value)
        case let value as UInt64:
            self = Int(value)
        default:
            let err = ScalarDecodingError.unexpectedScalarType(
                expected: "Int",
                received: codable.value
            )
            throw err
        }
    }
    
    public func encode() -> AnyCodable {
        AnyCodable(self)
    }
    
    public static let mockValue = 42
}

extension Bool: GraphQLScalar {
    public init(from codable: AnyCodable) throws {
        switch(codable.value) {
        case let value as Bool:
            self = value
        default:
            let err = ScalarDecodingError.unexpectedScalarType(
                expected: "String",
                received: codable.value
            )
            throw err
        }
    }
    
    public static let mockValue = true
}

extension Double: GraphQLScalar {
    public init(from codable: AnyCodable) throws {
        switch(codable.value) {
        case let value as Float:
            self = Double(value)
        case let value as Double:
            self = value
        default:
            let err = ScalarDecodingError.unexpectedScalarType(
                expected: "Double",
                received: codable.value
            )
            throw err
        }
    }
    
    public static let mockValue = 3.14
}



// MARK: - Error

public enum ScalarDecodingError: Error {
    
    /// Scalar expected a given type but received a value of a different type.
    case unexpectedScalarType(expected: String, received: Any)
    
    /// Scalar expected one of the enumerator String values but got an unexpected value.
    case unknownEnumCase(value: String)
    
    /// Code is trying to decode an input value.
    case decodingInputValue
}

extension ScalarDecodingError: Equatable {
    public static func == (lhs: ScalarDecodingError, rhs: ScalarDecodingError) -> Bool {
        switch (lhs, rhs) {
        case (.decodingInputValue, .decodingInputValue):
            return true
        case let (.unknownEnumCase(value: lval), .unknownEnumCase(value: rval)):
            return lval == rval
        default:
            return false
        }
    }
}

public enum ScalarEncodingError: Error {
    
    /// Error thrown when the code is trying to encode an absent value.
    case encodingAbsentValue
}
