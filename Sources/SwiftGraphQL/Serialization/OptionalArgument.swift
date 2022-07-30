import Foundation
import GraphQL

/// Tells whether a concreate type has a value.
///
/// To prevent encoding of absent values we use a the OptionalArgumentProtocol
/// in document parsing to figure out whether we should encode or skip the argument.
protocol OptionalArgumentProtocol {
    
    /// Tells whether an optional argument has a value.
    var hasValue: Bool { get }
}

/// OptionalArgument is a utility structure used to represent possibly absent values.
public struct OptionalArgument<T>: OptionalArgumentProtocol {
    
    /// Special structure that allows recursive type references.
    ///
    /// - NOTE: We encode `absent` as empty list, `present` as list with one value,
    ///         and `null` as null value.
    fileprivate enum InternalValue {
        case value([T])
        case null
    }
    
    /// Internal representation of the provided value that allows recursive types.
    private var _value: InternalValue

    // MARK: - Initializer

    public enum Value {
        
        /// Argument has given value.
        indirect case present(T)
        
        /// Argument has no value.
        case absent
        
        /// Argument has value, that value is `null`.
        case null
    }

    fileprivate init(_ value: Value) {
        switch value {
        case let .present(value):
            _value = .value([value])
        case .absent:
            _value = .value([])
        case .null:
            _value = .null
        }
    }

    // MARK: - Calculated Properties

    /// Returns the value of an optional argument.
    public var value: Value {
        switch _value {
        case let .value(value):
            if let value = value.first {
                return .present(value)
            }
            return .absent
        case .null:
            return .null
        }
    }

    /// Tells whether an optional argument has a value.
    public var hasValue: Bool {
        switch _value {
        case let .value(value) where value.isEmpty:
            return false
        default:
            return true
        }
    }
}

/// A utility type-alias that reduces the number of characters you need to type to create an optional argument value.
public typealias OptArg = OptionalArgument

// MARK: - Utility Initializers

public extension OptionalArgument {
    
    /// Converts optional value  so that `nil` becomes `null`.
    init(present value: T?) {
        switch value {
        case let .some(value):
            self.init(.present(value))
        case .none:
            self.init(.null)
        }
    }
   
    /// Converts optional value so that `nil` becomes `absent`.
    init(absent value: T? = nil) {
        switch value {
        case let .some(value):
            self.init(.present(value))
        case .none:
            self.init(.absent)
        }
        
    }
}

// MARK: - Transforming Optional Arguments

public extension OptionalArgument {
    
    /// Maps a value using provided function when the value is present.
    func map<A>(_ fn: (T) -> A) -> OptionalArgument<A> {
        switch value {
        case let .present(value):
            return OptionalArgument<A>(.present(fn(value)))
        case .absent:
            return OptionalArgument<A>(.absent)
        case .null:
            return OptionalArgument<A>(.null)
        }
    }

    /// Chain together multple transformations that each may fail.
    func andThen<V>(_ fn: (T) -> OptArg<V>) -> OptArg<V> {
        switch self.value {
        case .present(let value):
            return fn(value)
            
        case .null:
            return OptionalArgument<V>(.null)
            
        // If there's no value we don't do anything with it.
        case .absent:
            return OptionalArgument<V>(.absent)
        }
    }
}

// MARK: - Literal Expressions

extension OptionalArgument: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(.null)
    }
}
extension OptionalArgument: ExpressibleByBooleanLiteral where T == Bool {
    public init(booleanLiteral: Bool) {
        self.init(.present(booleanLiteral))
    }
}
extension OptionalArgument: ExpressibleByIntegerLiteral where T == Int {
    public init(integerLiteral: Int) {
        self.init(.present(integerLiteral))
    }
}
extension OptionalArgument: ExpressibleByFloatLiteral where T == Float {
    public init(floatLiteral: Float) {
        self.init(.present(floatLiteral))
    }
}

extension OptionalArgument:
    ExpressibleByUnicodeScalarLiteral,
        ExpressibleByStringLiteral,
        ExpressibleByExtendedGraphemeClusterLiteral where T == String {
    
    public init(unicodeScalarLiteral value: String) {
        self.init(present: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(.present(value))
    }

    public init(stringLiteral value: String) {
        self.init(.present(value))
    }
}

// MARK: - Utility Prefix
// https://www.avanderlee.com/swift/custom-operators-swift/

/// Converts a value to an optional argument.
public prefix func ~ <T>(value: T?) -> OptionalArgument<T> {
    OptionalArgument<T>(present: value)
}

// MARK: - Equatable, Hashable

extension OptionalArgument.InternalValue: Equatable where T: Equatable {}
extension OptionalArgument.InternalValue: Hashable where T: Hashable {}

extension OptionalArgument: Equatable where T: Equatable {}
extension OptionalArgument: Hashable where T: Hashable {}

extension OptionalArgument: Encodable where T: Encodable {
    
    /// Encodes an optional argument using given encoder.
    ///
    /// - Note: You should never encode an absent value. If you try, the encoder
    ///         is going to throw. Instead, you should check `hasValue` property
    ///         and make sure it is present.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case .absent:
            throw EncodingError.invalidValue(
                self,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Cannot encode absent value."
                )
            )
        case .null:
            try container.encodeNil()
        case let .present(value):
            try container.encode(value)
        }
    }
}
