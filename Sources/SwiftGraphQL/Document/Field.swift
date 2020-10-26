import Foundation

public enum GraphQLField {
    public typealias Name = String
//    public typealias Arguments = [String: Value]
    
    case composite(Name, [Argument], [GraphQLField])
    case leaf(Name, [Argument])
    
    // MARK: - Constructors
    
    /// Returns a leaf field with a given name.
    static public func leaf(name: Name, arguments: [Argument] = []) -> GraphQLField {
        .leaf(name, arguments)
    }
    
    /// Returns a composite GraphQLField.
    ///
    /// - Note: This is a shorthand for constructing leaf case yourself.
    static public func composite(name: Name, arguments: [Argument] = [], selection: [GraphQLField]) -> GraphQLField {
        .composite(name, arguments, selection)
    }
    
    // MARK: - Calculated properties
    
    /// Returns the name of a field.
    ///
    /// - Note: Used inside generated function decoders to know which field to look at.
    public var name: String {
        switch self {
        case .composite(let name, _, _):
            return name
        case .leaf(let field, _):
            return field
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
        }
    }
}

// MARK: - Utility extensions

extension Collection where Element == GraphQLField {
    /// Returns a collection of all arguments in subselection.
    var arguments: [Argument] {
        var arguments = [Argument]()
        self.forEach { arguments.append(contentsOf: $0.arguments) }
        
        return arguments
    }
}
