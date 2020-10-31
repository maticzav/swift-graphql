import Foundation

/**
    This file contains source code used for encoding and decoding selection.
 */



public enum GraphQLOperationType: String, CaseIterable {
    case query = "query"
    case mutation = "mutation"
    case subscription = "subscription"
}

extension Collection where Element == GraphQLField {
    /// Returns a GraphQL query for the current selection set.
    func serialize(for operationType: GraphQLOperationType) -> String {
        [ "\(operationType.rawValue)\(self.arguments.serializedForVariables) {",
          self.serialized.indent(by: 2).joined(separator: "\n"),
          "}"
        ].joined(separator: "\n")
    }
}
    
// MARK: - Private helpers

extension GraphQLField {
    fileprivate var serialized: [String] {
        switch self {
        case .leaf(let name, let arguments):
            return [ "\(self.alias!): \(name)\(arguments.serializedForArguments)" ]
        case .composite(let name, let arguments, let subselection):
            return
                [ "\(self.alias!): \(name)\(arguments.serializedForArguments) {",
                  "__typename".indent(by: 2)
                ] +
                subselection.serialized.indent(by: 2) +
                [ "}" ]
        case .fragment(let type, let subselection):
            return
                [ "...on \(type) {" ] +
                subselection.serialized.indent(by: 2) +
                [ "}" ]
        }
    }
}

extension Collection where Element == GraphQLField {
    /// Returns a GraphQL query for the current selection set.
    var serialized: [String] {
        self.flatMap { $0.serialized }
    }
}

// MARK: - Argument Serialization

extension Argument {
    /// Returns a serialized query parameter.
    var serializedForArgument: String {
        "\(self.name): $\(self.hash)"
    }
    
    /// Returns a serialized query variable.
    var serializedForVariable: String {
        "$\(self.hash): \(self.type)"
    }
}

extension Collection where Element == Argument {
    /// Returns the list of all argumetns that have a value.
    var present: [Argument] {
        self.compactMap {
            if $0.value == nil {
                return nil
            }
            return $0
        }
    }
    
    /// Serializes a collection of arguments into a query string.
    var serializedForArguments: String {
        /* Return empty string for no arguments. */
        if self.present.isEmpty {
            return ""
        }
        return "(\(self.present.map { $0.serializedForArgument }.joined(separator: ", ")))"

    }
    
    /// Returns serialized query variables.
    var serializedForVariables: String {
        // Return empty string if there's no arguments.
        if self.present.isEmpty {
            return ""
        }
        // Wrap them in parantheses otherwise.
        return "(\(self.present.map { $0.serializedForVariable }.joined(separator: ", ")))"
    }
}
