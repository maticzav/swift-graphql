import Foundation


/// Tells whether a concreate type has a value.
///
/// To prevent encoding of absent values we use a the OptionalArgumentProtocol
/// in document parsing to figure out whether we should encode or skip the argument.
protocol OptionalArgumentProtocol {
    
    /// Tells whether an optional argument has a value.
    var hasValue: Bool { get }
}

/// A utility type-alias that reduces the number of characters we need to type.
public typealias OptArg = OptionalArgument

/// OptionalArgument is a utility structure used to represent possibly absent values.
public struct OptionalArgument<T>: OptionalArgumentProtocol {
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

    // MARK: - Internal

    fileprivate enum InternalValue {
        /*
         There are three states a value can be in:
            - absent (value, but empty list),
            - null (there is a value - it's null),
            - present (value and list with a value)
         */
        case value([T])
        case null
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

// MARK: - Initializers

public extension OptionalArgument {
    
    /// Converts optional value to an optional argument so that `nil` becomes `null`.
    init(present value: T?) {
        switch value {
        case let .some(value):
            self.init(.present(value))
        case .none:
            self.init(.null)
        }
    }
   
    /// Maps optional value to an optional argument so that `nil` becomes `absent`.
    init(absent value: T? = nil) {
        switch value {
        case let .some(value):
            self.init(.present(value))
        case .none:
            self.init(.absent)
        }
        
    }
}

// MARK: - Modifier Methods

public extension OptionalArgument {
    
    /// Maps a value using provided function when present.
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

    /// Lets you bind the value and convert it.
//    public func andThen<T, V>(_ fn: (T) -> V) -> OptionalArgument<V> where T == Optional<T> {
//        switch self.value {
//        case .present(let value):
//            return OptionalArgument<V>(.present(fn(value)))
//        case .absent:
//            return OptionalArgument<V>(.absent)
//        case .null:
//            return OptionalArgument<V>(.null)
//        }
//    }
}

// MARK: - Protocols

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
