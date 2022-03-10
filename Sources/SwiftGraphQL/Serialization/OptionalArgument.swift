import Foundation

/*
 OptionalArgument is a utility structure used to denote a possibly
 absent value.

 To support not-encoding an absent value, I have created a protocol
 that we use in document parsing to figure out whether we
 should include or skip the argument.
 */

protocol OptionalArgumentProtocol {
    /// Tells whether an optional argument has a value.
    var hasValue: Bool { get }
}

public struct OptionalArgument<Type>: OptionalArgumentProtocol {
    private var _value: InternalValue

    // MARK: - Initializer

    public enum Value {
        indirect case present(Type)
        case absent
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
        case value([Type])
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
    init(present value: Type?) {
        switch value {
        case let .some(value):
            self = .present(value)
        case .none:
            self = .null()
        }
    }
   
    /// Maps optional value to an optional argument so that `nil` becomes `absent`.
    init(absent value: Type? = nil) {
        switch value {
        case let .some(value):
            self = .present(value)
        case .none:
            self = .absent()
        }
        
    }
    
    // MARK: - Static Descriptors


    /// Returns an OptionalArgument with a given value.
    static func present(_ value: Type) -> OptionalArgument<Type> {
        self.init(.present(value))
    }

    /// Returns an OptionalArgument with null value.
    static func null() -> OptionalArgument<Type> {
        self.init(.null)
    }

    /// Returns an OptionalArgument with absent value.
    static func absent() -> OptionalArgument<Type> {
        self.init(.absent)
    }
}

// MARK: - Modifier Methods

public extension OptionalArgument {
    /// Maps a value using provided function when present.
    func map<A>(_ fn: (Type) -> A) -> OptionalArgument<A> {
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
//    public func andThen<T, V>(_ fn: (Type) -> V) -> OptionalArgument<V> where Type == Optional<T> {
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

extension OptionalArgument.InternalValue: Equatable where Type: Equatable {}
extension OptionalArgument.InternalValue: Hashable where Type: Hashable {}

extension OptionalArgument: Equatable where Type: Equatable {}
extension OptionalArgument: Hashable where Type: Hashable {}

extension OptionalArgument: Encodable where Type: Encodable {
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
