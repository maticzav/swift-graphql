import Foundation

/// GraphQLField represents a value in the selection. It contains information about
/// what the selection should be and what the selected types are.
///
/// - NOTE: `interface` field in the `fragment` field may be a union or an interface.
public enum GraphQLField {
    public typealias SelectionSet = [GraphQLField]

    case composite(field: String, type: String, arguments: [Argument], selection: SelectionSet)
    case leaf(field: String, arguments: [Argument])
    case fragment(type: String, interface: String, selection: SelectionSet)

    // MARK: - Calculated properties

    /// Returns the name of a field.
    ///
    /// - Note: Used inside generated function decoders to know which field to look at.
    public var name: String {
        switch self {
        case .composite(let name, _, _, _),
                .leaf(let name, _),
                .fragment(let name, _, _):
            return name
        }
    }

    /*
     We calculate alias using a hash value of the argument. Firstly,
     we have to define a query variable that we use in the query document and
     reference in variables. Secondly, we have to create a variable reference.

     `alias` and `arguments` properties are internal utility functions that
     let the network function collect all the queries in the document tree.
     */

    /// Returns the alias of the value based on arguments.
    ///
    /// - Note: Fragments don't have alias.
    public var alias: String? {
        switch self {
        case let .leaf(name, arguments), let .composite(name, _, arguments, _):
            return "\(name.camelCase)_\(arguments.hash)"
        case .fragment:
            return nil
        }
    }

    /// Returns the list of all arguments in the selection tree.
    var arguments: [Argument] {
        switch self {
        case let .leaf(_, arguments):
            return arguments
        case .composite(_, _, var arguments, let selection):
            for subSelection in selection {
                arguments.append(contentsOf: subSelection.arguments)
            }
            return arguments
        case let .fragment(_, _, selection):
            var arguments = [Argument]()
            for subSelection in selection {
                arguments.append(contentsOf: subSelection.arguments)
            }
            return arguments
        }
    }
    
    /// Returns a list of types related to the selection. This may be useful in cache invalidation.
    var types: [String] {
        switch self {
        case .leaf:
            return []
            
        case .composite(_, let type, _, let selection):
            return ([type] + selection.flatMap { $0.types }).unique(by: { $0 })
            
        case .fragment(_, let interface, let selection):
            return ([interface] + selection.flatMap { $0.types }).unique(by: { $0 })
        }
    }

    // MARK: - Public Utility Functions

    /// Returns the type from field alias.
    public static func getFieldNameFromAlias(_ alias: String) -> String {
        let parts = alias.split(separator: "_")
        return String(parts[0])
    }
}

// MARK: - Utility extensions

extension Collection where Element == GraphQLField {
    /// Returns a collection of all arguments in subselection.
    var arguments: [Argument] {
        flatMap { $0.arguments }
    }
}
