import Foundation

extension GraphQL {
    indirect public enum InvertedTypeRef<Type> {
        case named(Type)
        case nullable(InvertedTypeRef)
        case list(InvertedTypeRef)
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
