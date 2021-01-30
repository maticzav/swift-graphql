import Foundation

public enum GraphQLField {
    public typealias SelectionSet = [GraphQLField]
    
    case composite(String, [Argument], SelectionSet)
    case leaf(String, [Argument])
    case fragment(String, SelectionSet)
    
    // MARK: - Constructors
    
    /// Returns a leaf field with a given name.
    static public func leaf(name: String, arguments: [Argument] = []) -> GraphQLField {
        .leaf(name, arguments)
    }
    
    /// Returns a composite GraphQLField.
    ///
    /// - Note: This is a shorthand for constructing composite yourself.
    static public func composite(name: String, arguments: [Argument] = [], selection: SelectionSet) -> GraphQLField {
        .composite(name, arguments, selection)
    }
    
    /// Returns a fragment GraphQLField.
    ///
    /// - Note: This is a shorthand for constructing fragment yourself.
    static public func fragment(type: String, selection: SelectionSet) -> GraphQLField {
        .fragment(type, selection)
    }
    
    // MARK: - Calculated properties
    
    /// Returns the name of a field.
    ///
    /// - Note: Used inside generated function decoders to know which field to look at.
    public var name: String {
        switch self {
        case .composite(let name, _, _),
             .leaf(let name, _),
             .fragment(let name, _):
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
        case .leaf(let name, let arguments),
             .composite(let name, let arguments, _):
            return "\(name.camelCase)_\(arguments.hash)"
        case .fragment(_, _):
            return nil
        }
    }
    
    /// Returns the list of all arguments in the selection tree.
    var arguments: [Argument] {
        switch self {
        case .leaf(_, let arguments):
            return arguments
        case .composite(_, var arguments, let selection):
            for subSelection in selection {
                arguments.append(contentsOf: subSelection.arguments)
            }
            return arguments
        case .fragment(_, let selection):
            var arguments = [Argument]()
            for subSelection in selection {
                arguments.append(contentsOf: subSelection.arguments)
            }
            return arguments
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
        self.flatMap { $0.arguments }
    }
}
