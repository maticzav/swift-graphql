import GraphQLAST

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
            static var operation: String { \"\(operation)\" }
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
