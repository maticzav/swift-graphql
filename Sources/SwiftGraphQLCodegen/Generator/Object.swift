import Foundation
import GraphQLAST
import SwiftAST

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateObject(_ type: ObjectType) throws -> [String] {
        let name = type.name.pascalCase

        /* Code */
        var code = [String]()

        /* Definition */
        code.append("extension Objects {")
        code.append(contentsOf:
            try generateEncodableStruct(
                name,
                fields: type.fields
            )
        )
        code.append("}")

        // MARK: TODO: availability, IDE selection.

        /* Decoder */
        /*
         We make conformance to decodable an extension so we can still leverage
         the default init a struct gets.
         */
        code.append("extension Objects.\(name): Decodable {")
        code.append(contentsOf: try generateDecodableExtension(fields: type.fields))
        code.append("}")

        code.append("")
        
        /* Fields */
        code.append("extension Fields where TypeLock == Objects.\(name) {")
        code.append(contentsOf: try type.fields.flatMap { try generateField($0) })
        code.append("}")
        
        // MARK: TODO: selection

        return code
    }
}

extension ObjectType: BlockProtocol {
    public var block: Block {
        .blocks([])
    }
}
