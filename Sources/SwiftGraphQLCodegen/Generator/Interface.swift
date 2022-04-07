import Foundation
import GraphQLAST
import SwiftGraphQL

/*
 This file contains the code that we use to generate interfaces.
 Interfaces generate a selection for common fields as well as discriminating
 function that allows developers to select fields from a union type.
 */

extension InterfaceType: Structure {}

extension InterfaceType {
    
    /// Returns a code that represents an interface.
    ///
    /// - parameter objects: List of all objects in the schema.
    func declaration(objects: [ObjectType], context: Context) throws -> String {
        let name = self.name.pascalCase
        
        let definition = try self.definition(name: name, objects: objects, context: context)
        let fields = try self.fields.getDynamicSelections(parent: self.name, context: context)

        return """
        extension Interfaces {
        \(definition)
        }

        extension Fields where TypeLock == Interfaces.\(name) {
        \(fields)
        }

        \(possibleTypes.selection(name: "Interfaces.\(name)", objects: objects))

        extension Selection where TypeLock == Never, Type == Never {
            typealias \(name)<T> = Selection<T, Interfaces.\(name)>
        }
        """
    }
}
