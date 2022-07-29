import Foundation
import GraphQLAST
import SwiftGraphQL

extension ObjectType: Structure {
    var possibleTypes: [ObjectTypeRef] {
        [ObjectTypeRef.named(ObjectRef.object(name))]
    }
}

extension ObjectType {
    
    /// Creates deifnitions used by SwiftGraphQL to make selection and decode a particular object.
    ///
    /// - parameter objects: All objects in the schema.
    /// - parameter alias: Tells whether the generated code should include utility `Selection.Type` alias.
    func declaration(objects: [ObjectType], context: Context, alias: Bool = true) throws -> String {
        let apiName = self.name.pascalCase
        
        let definition = try self.definition(name: apiName, objects: objects, context: context)
        let selection = try self.fields.getDynamicSelections(parent: self.name, context: context)
        
        var code = """
        extension Objects {
        \(definition)
        }

        extension Fields where TypeLock == Objects.\(apiName) {
        \(selection)
        }
        
        """
        
        guard alias else {
            return code
        }
        
        // Adds utility alias for the selection.
        code.append("""
        extension Selection where T == Never, TypeLock == Never {
            typealias \(apiName)<T> = Selection<T, Objects.\(apiName)>
        }
        """)
        
        return code
    }
    
    /// Generates utility code that may be used to select a single field from the object using a static function.
    ///
    /// - parameter alias: Tells whether the code should include utility reference in `Selection.Type`.
    func statics(context: Context) throws -> String {
        let name = self.name.pascalCase
        let selections = try self.fields.getStaticSelections(for: self, context: context)
        
        let code = """
        extension Objects.\(name) {
        \(selections)
        }
        """
        
        return code
    }
}
