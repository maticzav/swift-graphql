import Foundation

/// Inverted type reference represents a reference using nullable references
/// instead of required ones. This makes some calculations easier.
public indirect enum InvertedTypeRef<Type> {
    case named(Type)
    case nullable(InvertedTypeRef)
    case list(InvertedTypeRef)

    // MARK: - Calculated properties

    /// Returns a nullable instance of self.
    public var nullable: InvertedTypeRef<Type> {
        self.inverted.nullable.inverted
    }

    /// Returns a non nullable instance of self.
    public var nonNullable: InvertedTypeRef<Type> {
        switch self {
        case let .nullable(subref):
            return subref
        default:
            return self
        }
    }
}

public extension InvertedTypeRef {
    /// Returns the bottom most named type in reference.
    var namedType: Type {
        switch self {
        case let .named(type):
            return type
        case let .nullable(subRef), let .list(subRef):
            return subRef.namedType
        }
    }
}

extension InvertedTypeRef: Equatable where Type: Equatable {}

// MARK: - Conversion

public extension TypeRef {
    /// Turns a regular reference into an inverted reference that presents
    /// fields as regular (i.e. required) or nullable instead of regular (i.e. nulalble) or required.
    var inverted: InvertedTypeRef<Type> {
        switch self {
        case let .named(named):
            return .nullable(.named(named))
        case let .list(ref):
            return .nullable(.list(ref.inverted))
        case let .nonNull(ref):
            /* Remove nullable wrapper. */
            switch ref.inverted {
            case let .nullable(subRef):
                return subRef
            default:
                return ref.inverted
            }
        }
    }
}

public extension InvertedTypeRef {
    /// Turns an inverted reference back into a regular reference.
    var inverted: TypeRef<Type> {
        switch self {
        case let .named(named):
            return .nonNull(.named(named))
        case let .list(ref):
            return .nonNull(.list(ref.inverted))
        case let .nullable(ref):
            switch ref.inverted {
            /* Remove nonnullable wrapper. */
            case let .nonNull(subRef):
                return subRef
            default:
                return ref.inverted
            }
        }
    }
}

// MARK: - Type Alias

public typealias InvertedNamedTypeRef = InvertedTypeRef<NamedRef>
public typealias InvertedOutputTypeRef = InvertedTypeRef<OutputRef>
public typealias InvertedInputTypeRef = InvertedTypeRef<InputRef>
