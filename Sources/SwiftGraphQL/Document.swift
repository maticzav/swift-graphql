import Foundation

/*
 This file contains source code used for encoding and decoding selection.
 */

extension Collection where Element == GraphQLField {
    /// Returns a GraphQL query for the current selection set.
    func serialize(for operationType: String) -> String {
        serialize(for: operationType, operationName: nil)
    }

    /// Returns a GraphQL query for the current selection set.
    func serialize(for operationType: String, operationName: String?) -> String {
        // http://spec.graphql.org/June2018/#sec-Language.Operations
        let operationDefinition: String = [
            operationType,
            operationName,
            arguments.serializedForVariables,
        ].compactMap { $0 }.joined(separator: " ")

        // http://spec.graphql.org/June2018/#sec-Selection-Sets
        let query = [
            "\(operationDefinition) {",
            serialized.indent(by: 2).joined(separator: "\n"),
            "}",
        ].joined(separator: "\n")

        return query
    }
}

// MARK: - Private helpers

private extension GraphQLField {
    var serialized: [String] {
        switch self {
        case let .leaf(name, arguments):
            return ["\(alias!): \(name)\(arguments.serializedForArguments)"]
        case let .composite(name, arguments, subselection):
            return
                ["\(alias!): \(name)\(arguments.serializedForArguments) {",
                 "__typename".indent(by: 2)] +
                subselection.serialized.indent(by: 2) +
                ["}"]
        case let .fragment(type, subselection):
            return
                ["...on \(type) {"] +
                subselection.serialized.indent(by: 2) +
                ["}"]
        }
    }
}

extension Collection where Element == GraphQLField {
    /// Returns a GraphQL query for the current selection set.
    var serialized: [String] {
        flatMap { $0.serialized }
    }
}

// MARK: - Argument Serialization

extension Argument {
    /// Returns a serialized query parameter.
    var serializedForArgument: String {
        "\(name): $\(hash)"
    }

    /// Returns a serialized query variable.
    var serializedForVariable: String {
        "$\(hash): \(type)"
    }
}

extension Collection where Element == Argument {
    /// Returns the list of all argumetns that have a value.
    var present: [Argument] {
        compactMap {
            if $0.value == nil {
                return nil
            }
            return $0
        }
    }

    /// Serializes a collection of arguments into a query string.
    var serializedForArguments: String {
        /* Return empty string for no arguments. */
        if present.isEmpty {
            return ""
        }
        return "(\(present.map { $0.serializedForArgument }.joined(separator: ", ")))"
    }

    /// Returns serialized query variables.
    var serializedForVariables: String? {
        // Return empty string if there's no arguments.
        if present.isEmpty {
            return nil
        }

        let args = present
            .unique(by: { $0.hash })
            .map { $0.serializedForVariable }
            .joined(separator: ", ")

        // Wrap them in parantheses otherwise.
        return "(\(args))"
    }
}
