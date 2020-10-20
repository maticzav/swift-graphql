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
}
