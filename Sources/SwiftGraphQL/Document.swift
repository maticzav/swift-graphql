import Foundation

/**
    This file contains source code used for encoding and decoding selection.
 */

extension Collection where Element == GraphQLField {
    /// Returns a GraphQL query for the current selection set.
    func serialize(for operationType: GraphQLOperationType) -> String {
        """
        \(operationType.rawValue) {
        \(self.map { serializeSelection($0, level: 1) }.joined(separator: "\n"))
        }
        """
    }
    
    private func serializeSelection(_ selection: GraphQLField, level indentation: Int) -> String {
        switch selection {
        case .leaf(_, let arguments):
            return "\(generateIndentation(level: indentation))\(selection.name)\(arguments.serialize())"
        case .composite(_, let arguments, let subSelection):
            return """
            \(generateIndentation(level: indentation))\(selection.name)\(arguments.serialize()) {
            \(subSelection.map { serializeSelection($0, level: indentation + 1) }.joined(separator: "\n"))
            \(generateIndentation(level: indentation))}
            """
        }
    }
    
    private func generateIndentation(level: Int) -> String {
        String(repeating: " ", count: level * 2)
    }
}

public enum GraphQLOperationType: String, CaseIterable {
    case query = "query"
    case mutation = "mutation"
    case subscription = "subscription"
}
    
