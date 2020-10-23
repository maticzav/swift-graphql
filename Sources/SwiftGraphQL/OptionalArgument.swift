import Foundation

public enum OptionalArgument<Type> {
    case present(Type)
    case null
    case absent
}

// MARK: - Initializers

extension OptionalArgument {
    init(optional: Optional<Type>) {
        switch optional {
        case .some(let value):
            self = .present(value)
        case .none:
            self = .absent
        }
    }
}

// MARK: - Methods

extension OptionalArgument {
    /// Maps a value using provided function when present.
    func map<A>(_ fn: (Type) -> A) -> OptionalArgument<A> {
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

extension OptionalArgument: Equatable where Type: Equatable {}

extension OptionalArgument: Encodable where Type: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .absent:
            ()
        case .null:
            try container.encodeNil()
        case .present(let value):
            try container.encode(value)
        }
    }
}
