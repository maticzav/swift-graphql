import Foundation

/**
 This file contains code used to generate type-locks for selection set.
 */

extension GraphQLCodegen {
    /// Generates an object phantom type entry.
    static func generatePhantomTypes(for types: [GraphQL.NamedType]) -> String {
        """
        enum Object {
        \(types.map { generatePhantomType(for: $0) }.joined(separator: "\n"))
        }
        
        \(types.map { generatePhantomTypeAlias(for: $0)}.joined(separator: "\n"))
        """
    }
    
    private static func generatePhantomType(for type: GraphQL.NamedType) -> String {
        """
            enum \(type.type.name.pascalCase) {}
        """
    }
    
    private static func generatePhantomTypeAlias(for type: GraphQL.NamedType) -> String {
        "typealias \(type.type.name.pascalCase)Object = Object.\(type.type.name.pascalCase)"
    }
}
