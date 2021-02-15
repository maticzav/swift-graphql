import Foundation
import GraphQLAST

extension ObjectType: Structure {
    var possibleTypes: [ObjectTypeRef] {
        [ObjectTypeRef.named(ObjectRef.object(name))]
    }
}

extension ObjectType {
    /// Declares (i.e. creates) the object itself.
    func declaration(objects: [ObjectType], scalars: ScalarMap) throws -> String {
        let name = self.name.pascalCase

        return """
        extension Objects {
        \(try self.struct(name: name, objects: objects, scalars: scalars))
        }

        extension Objects.\(name): Decodable {
        \(try allFields(objects: objects).decoder(scalars: scalars))
        }

        extension Fields where TypeLock == Objects.\(name) {
        \(try fields.selection(scalars: scalars))
        }

        extension Selection where TypeLock == Never, Type == Never {
            typealias \(name)<T> = Selection<T, Objects.\(name)>
        }
        """
    }
}
