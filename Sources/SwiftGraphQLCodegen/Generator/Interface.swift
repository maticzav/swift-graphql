import Foundation
import GraphQLAST

/*
 This file contains the code that we use to generate interfaces.
 Interfaces generate a selection for common fields as well as discriminating
 function that allows developers to select fields from a union type.
 */

extension InterfaceType: Structure {}

extension InterfaceType {
    /// Returns a code that represents an interface.
    func declaration(objects: [ObjectType], scalars: ScalarMap) throws -> String {
        let name = self.name.pascalCase

        return """
        extension Interfaces {
        \(try self.struct(name: name, objects: objects, scalars: scalars))
        }

        extension Interfaces.\(name): Decodable {
        \(try allFields(objects: objects).decoder(scalars: scalars, includeTypenameDecoder: true))
        }

        extension Fields where TypeLock == Interfaces.\(name) {
        \(try fields.selection(scalars: scalars))
        }

        \(possibleTypes.selection(name: "Interfaces.\(name)", objects: objects))

        extension Selection where TypeLock == Never, Type == Never {
            typealias \(name)<T> = Selection<T, Interfaces.\(name)>
        }
        """
    }
}
