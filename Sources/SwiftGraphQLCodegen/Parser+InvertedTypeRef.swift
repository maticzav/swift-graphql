extension GraphQL {
    indirect public enum InvertedTypeRef: Equatable {
        case named(GraphQL.NamedType)
        case nullable(InvertedTypeRef)
        case list(InvertedTypeRef)
    }
}

// MARK: - Conversions

extension GraphQL.TypeRef {
    public var inverted: GraphQL.InvertedTypeRef {
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
    public var inverted: GraphQL.TypeRef {
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
