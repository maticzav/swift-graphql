import GraphQLAST
import SwiftGraphQLUtils

extension Operation {
    
    /// Tells whether the operation is a subscription.
    var isSubscription: Bool {
        switch self {
        case .subscription:
            return true
        default:
            return false
        }
    }
    
    /// Returns a definition of an operation.
    func declaration() -> String {
        """
        extension Objects.\(type.name.pascalCase): \(self.protocol) {
            public static var operation: GraphQLOperationKind { .\(operation) }
        }
        """
    }

    private var operation: String {
        switch self {
        case .query:
            return "query"
        case .mutation:
            return "mutation"
        case .subscription:
            return "subscription"
        }
    }

    private var `protocol`: String {
        switch self {
        case .query, .mutation:
            return "GraphQLHttpOperation"
        case .subscription:
            return "GraphQLWebSocketOperation"
        }
    }
}
