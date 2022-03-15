import Foundation
import SwiftGraphQL

extension GraphQLOperation {
    
    /// Turns GraphQLOperation into an operation kind.
    static var operationKind: Operation.Kind {
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
