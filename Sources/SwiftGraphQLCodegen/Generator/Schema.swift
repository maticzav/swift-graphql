import Foundation
import GraphQLAST
import SwiftAST

extension Schema: BlockProtocol {
    public var block: Block {
        /* Data */

        let operationsPart = try operations.map {
            try generateOperation(type: $0.type, operation: $0.operation)
        }

        let objectsPart = try objects.map {
            try generateObject($0)
        }

        let interfacesPart = try interfaces.map {
            try generateInterface($0, with: objects)
        }

        let unionsPart = try unions.map {
            try generateUnion($0, with: objects)
        }

        let enumsPart = enums.map {
            generateEnum($0)
        }

        let inputObjectsPart = try inputObjects.map {
            try generateInputObject($0.name.pascalCase, for: $0)
        }

        
        return .blocks([
            Import(),
            .namespace("Operations", self.operations),
            .namespace("Objects"),
            .namespace("Interfaces"),
            .namespace("Unions"),
            .namespace("Enums"),
            .namespace("InputObjects")
        ])
    }
}
