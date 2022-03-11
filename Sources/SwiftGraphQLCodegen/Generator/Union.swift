import Foundation
import GraphQLAST

/*
 This file contains code used to generate unions.
 Unions consist of an overarching structure definition and
 */

extension UnionType: Structure {
    var fields: [Field] { [] }
}

extension UnionType {
    /// Returns a declaration of the union type that we add to the generated file.
    func declaration(objects: [ObjectType], context: Context) throws -> String {
        let name = self.name.pascalCase
        let definition = try self.struct(name: name, objects: objects, context: context)
        let decoders = try allFields(objects: objects, context: context)
            .decoders(context: context, includeTypenameDecoder: true)
        
        let selections = possibleTypes.selection(name: "Unions.\(name)", objects: objects)
        
        return """
        extension Unions {
        \(definition)
        }

        extension Unions.\(name): Decodable {
        \(decoders)
        }

        \(selections)

        extension Selection where TypeLock == Never, Type == Never {
            typealias \(name)<T> = Selection<T, Unions.\(name)>
        }
        """
    }
}
