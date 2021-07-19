import GraphQLAST

extension Operation {
    /// Returns a definition of an operation.
    func declaration() -> String {
        """
        extension Objects.\(type.name): \(self.protocol) {
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
