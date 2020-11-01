import Foundation
import Enumeration

/*
 OptionalArgument is a utility enumerator used to denote a possibly
 absent value.
 
 To support not-encoding an absent value, I have created a protocol
 that we use in document parsing to figure out whether we
 should include or skip the argument.
 */

protocol OptionalArgumentProtocol {
    /// Tells whether an optional argument has a value.
    var hasValue: Bool { get }
}

public enum OptionalArgument<Type>: OptionalArgumentProtocol {
    case present(Type)
    case null
    case absent
    
    // MARK: - Calculated Properties
    
    /// Tells whether an optional argument has a value.
    public var hasValue: Bool {
        switch self {
        case .absent:
            return false
        default:
            return true
        }
    }
}

// MARK: - Initializers

extension OptionalArgument {
    
    /// Returns a null argument in null and present otherwise.
    public init(optional: Optional<Type>) {
        switch optional {
        case .some(let value):
            self = .present(value)
        case .none:
            self = .null
        }
    }
    
    /// Returns an optional with present value.
    public init(value: Type) {
        self = .present(value)
    }
}

// MARK: - Methods

extension OptionalArgument {
    /// Maps a value using provided function when present.
    public func map<A>(_ fn: (Type) -> A) -> OptionalArgument<A> {
        switch self {
        case .present(let value):
            return .present(fn(value))
        case .absent:
            return .absent
        case .null:
            return .null
        }
    }
}

// MARK: - Protocols

/* We need the following protocols to conform to the */

extension OptionalArgument: Equatable where Type: Equatable {}
extension OptionalArgument: Hashable where Type: Hashable {}
extension OptionalArgument: Encodable where Type: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .absent:
            throw EncodingError
                
            )
        case .null:
            try container.encodeNil()
        case .present(let value):
            try container.encode(value)
        }
    }
}
