import Foundation
import GraphQLAST
import SwiftGraphQLUtils

/*
 This file contains code used to generate unions.
 Unions consist of an overarching structure definition and
 */

extension UnionType: Structure {
    var fields: [Field] {
        [] // Unions come with no predefined fields.
    }
}

extension UnionType {
    
    /// Returns a declaration of the union type that we add to the generated file.
    /// - parameter objects:
    func declaration(objects: [ObjectType], context: Context) throws -> String {
        let name = self.name.pascalCase
        let selections = possibleTypes.selection(name: "Unions.\(name)", objects: objects)
        
        return """
        extension Unions {
            public struct \(name) {}
        }

        \(selections)

        extension Selection where T == Never, TypeLock == Never {
            public typealias \(name)<W> = Selection<W, Unions.\(name)>
        }
        """
    }
}
