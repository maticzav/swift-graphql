import Foundation

public enum GraphQLField {
    case composite(String, [GraphQLField])
    case leaf(Field)
    
    // MARK: - Constructors
    
    /// Returns a leaf field with a given name.
    static public func leaf(name: String) -> GraphQLField {
        .leaf(Field(name: name))
    }
    
    /// Returns a composite GraphQLField.
    ///
    /// - Note: This is a shorthand for constructing leaf case yourself.
    static public func composite(name: String, selection: [GraphQLField]) -> GraphQLField {
        .composite(name, selection)
    }
    
    // MARK: - Calculated properties
    
    /// Returns the name of a field.
    ///
    /// - Note: Used inside generated function decoders to know which field to look at.
    public var name: String {
        switch self {
        case .composite(let name, _):
            return name
        case .leaf(let field):
            return field.name
        }
    }
    
    // MARK: - Field
    
    public struct Field {
        var name: String
    }
}

/* */

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
        case .leaf(let field):
            return "\(generateIndentation(level: indentation))\(field.name)"
        case .composite(let name, let selection):
            return """
            \(generateIndentation(level: indentation))\(name) {
            \(selection.map { serializeSelection($0, level: indentation + 1) }.joined(separator: "\n"))
            \(generateIndentation(level: indentation))}
            """
        }
    }
    
    private func generateIndentation(level: Int) -> String {
        String(repeating: " ", count: level * 2)
    }
}

enum GraphQLOperationType: String, CaseIterable {
    case query = "query"
    case mutation = "mutation"
    case subscription = "subscription"
}
    

