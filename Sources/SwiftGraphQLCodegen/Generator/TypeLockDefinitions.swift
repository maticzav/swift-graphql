import Foundation

/**
 This file contains code used to generate type-locks for selection set.
 */

extension GraphQLCodegen {
    /// Generates an object phantom type entry.
    static func generatePhantomTypes(for types: [GraphQL.NamedType]) -> String {
        """
        enum Object {
        \(types.map { generatePhantomType(for: $0) }
            .compactMap { $0 }
            .map { "    \($0)"}
            .joined(separator: "\n")
        )
        }
        
        \(types.map { generatePhantomTypeAlias(for: $0)}
            .compactMap { $0 }
            .joined(separator: "\n")
        )
        """
    }
    
    private static func generatePhantomType(for type: GraphQL.NamedType) -> String? {
        getPhantomTypeName(for: type).map { "enum \($0) {}" }
    }
    
    private static func generatePhantomTypeAlias(for type: GraphQL.NamedType) -> String? {
        getPhantomTypeName(for: type).map { "typealias \($0)Object = Object.\($0)" }
    }
    
    private static func getPhantomTypeName(for type: GraphQL.NamedType) -> String? {
        switch type {
        case .scalar(_), .union(_), .enum(_), .interface(_):
            return nil
        case .object(let object):
            return object.name.pascalCase
        case .inputObject(let inputObject):
            return inputObject.name.pascalCase
        }
    }
}
