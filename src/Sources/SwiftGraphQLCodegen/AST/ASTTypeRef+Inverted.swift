import Foundation

extension GraphQL {
    indirect public enum InvertedTypeRef<Type> {
        case named(Type)
        case nullable(InvertedTypeRef)
        case list(InvertedTypeRef)
        
        // MARK: - Calculated properties
        
        /// Returns a nullable instance of self.
        var nullable: InvertedTypeRef<Type> {
            self.inverted.nullable.inverted
        }
        
        /// Returns a non nullable instance of self.
        var nonNullable: InvertedTypeRef<Type> {
            switch self {
            case .nullable(let subref):
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
        case .named(let type):
            return type
        case .nullable(let subRef), .list(let subRef):
            return subRef.namedType
        }
    }
}

extension GraphQL.InvertedTypeRef: Equatable where Type: Equatable {}

// MARK: - Conversion

extension GraphQL.TypeRef {
    var inverted: GraphQL.InvertedTypeRef<Type> {
        switch self {
        case .named(let named):
            return .nullable(.named(named))
        case .list(let ref):
            return .nullable(.list(ref.inverted))
        case .nonNull(let ref):
            /* Remove nullable wrapper. */
            switch ref.inverted {
            case .nullable(let subRef):
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
        case .named(let named):
            return .nonNull(.named(named))
        case .list(let ref):
            return .nonNull(.list(ref.inverted))
        case .nullable(let ref):
            switch ref.inverted {
            /* Remove nonnullable wrapper. */
            case .nonNull(let subRef):
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
