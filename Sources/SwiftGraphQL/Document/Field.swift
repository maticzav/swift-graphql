import Foundation

/// GraphQLField represents a value in the selection. It contains information about
/// what the selection should be and what the selected types are.
///
/// - NOTE: `interface` field in the `fragment` field may be a union or an interface.
public enum GraphQLField {
    public typealias SelectionSet = [GraphQLField]

    /// Composite field describes a selection on an object an union or an interface.
    /// - parameter parent: Tells what type holds this field.
    /// - parameter type: Tells what the return type of the field is.
    case composite(field: String, parent: String, type: String, arguments: [Argument], selection: SelectionSet)
    
    /// Leaf field describes a scalar selection on a given type.
    /// - parameter parent: Tells what type holds this field.
    case leaf(field: String, parent: String, arguments: [Argument])
    
    /// Fragment selection describes an inline fragment.
    /// - parameter type: Tells what type we are making a selection for.
    /// - parameter interface: Tells what union or interface this fragment belongs to.
    case fragment(type: String, interface: String, selection: SelectionSet)

    // MARK: - Calculated properties

    /// Returns the name of a field.
    ///
    /// - Note: Used inside generated function decoders to know which field to look at.
    public var name: String {
        switch self {
        case .composite(let name, _, _, _, _),
                .leaf(let name, _, _),
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
        case let .leaf(name, parent, arguments),
            let .composite(name, parent, _, arguments, _):
            return "\(name.camelCase)\(parent.camelCase)_\(arguments.hash)"
        case .fragment:
            return nil
        }
    }

    /// Returns the list of all arguments in the selection tree.
    var arguments: [Argument] {
        switch self {
        case let .leaf(_, _, arguments):
            return arguments
        case .composite(_, _, _, var arguments, let selection):
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
    
    /// Returns a list of types related to the selection.
    ///
    /// - NOTE: This may be useful in cache invalidation.
    var types: Set<String> {
        switch self {
        case .leaf:
            return Set()
            
        case .composite(_, _, let type, _, let selection):
            var types = Set<String>()
            types.insert(type)
            for sub in selection {
                types = types.union(sub.types)
            }
            
            return types
            
        case .fragment(_, let interface, let selection):
            var types = Set<String>()
            types.insert(interface)
            for sub in selection {
                types = types.union(sub.types)
            }
            
            return types
        }
    }

    // MARK: - Public Utility Functions

    /// Returns the type-field signature from field alias.
    ///
    /// - NOTE: We use this to figure out which decoder to use for a parituclar field.
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
