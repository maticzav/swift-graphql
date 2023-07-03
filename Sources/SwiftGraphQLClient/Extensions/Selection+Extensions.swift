import Foundation

#if canImport(SwiftGraphQL)
import SwiftGraphQL

extension GraphQLOperation {
    
    /// Turns GraphQLOperation into an operation kind.
    public static var operationKind: Operation.Kind {
        switch Self.operation {
        case .query:
            return .query
        case .mutation:
            return .mutation
        case .subscription:
            return .subscription
        }
    }
}
#endif
