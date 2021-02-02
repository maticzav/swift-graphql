import Foundation

public extension GraphQL {
    indirect enum InvertedTypeRef<Type> {
        case named(Type)
        case nullable(InvertedTypeRef)
        case list(InvertedTypeRef)

        // MARK: - Calculated properties

        /// Returns a nullable instance of self.
        var nullable: InvertedTypeRef<Type> {
            inverted.nullable.inverted
        }

        /// Returns a non nullable instance of self.
        var nonNullable: InvertedTypeRef<Type> {
            switch self {
            case let .nullable(subref):
                return subref
            default:
                return self
            }
        }
    }
}

extension GraphQL.InvertedTypeRef {
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

extension GraphQL.InvertedTypeRef: Equatable where Type: Equatable {}

// MARK: - Conversion

extension GraphQL.TypeRef {
    var inverted: GraphQL.InvertedTypeRef<Type> {
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

extension GraphQL.InvertedTypeRef {
    var inverted: GraphQL.TypeRef<Type> {
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

extension GraphQL {
    typealias InvertedNamedTypeRef = InvertedTypeRef<NamedRef>
    typealias InvertedOutputTypeRef = InvertedTypeRef<OutputRef>
    typealias InvertedInputTypeRef = InvertedTypeRef<InputRef>
}
