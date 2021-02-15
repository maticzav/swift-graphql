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
    func declaration(objects: [ObjectType], scalars: ScalarMap) throws -> String {
        let name = self.name.pascalCase

        return """
        extension Unions {
        \(try self.struct(name: name, objects: objects, scalars: scalars))
        }

        extension Unions.\(name): Decodable {
        \(try allFields(objects: objects).decoder(scalars: scalars, includeTypenameDecoder: true))
        }

        \(possibleTypes.selection(name: "Unions.\(name)", objects: objects))

        extension Selection where TypeLock == Never, Type == Never {
            typealias \(name)<T> = Selection<T, Unions.\(name)>
        }
        """
    }
}
