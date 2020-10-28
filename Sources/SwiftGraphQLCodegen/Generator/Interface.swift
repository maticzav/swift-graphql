import Foundation

/**
 Interfaces generates an object type as well as possible type extensions.
 */

//extension GraphQLCodegen {
//    /// Generates a function to handle a type.
//    func generateInterface(
//        _ type: GraphQL.InterfaceType,
//        operation: Operation? = nil
//    ) throws -> [String] {
//        let name = type.name.pascalCase
//        let identifier = "\(name)Interface"
//        let object = GraphQL.ObjectType(
//            name: type.name,
//            description: type.description,
//            fields: type.fields,
//            interfaces: type.interfaces
//        )
//        
//        /* Code */
//        let foo = generateObject(identifier, for: <#T##GraphQL.ObjectType#>)
//        
//        let code = try
//            [ "/* \(type.name) */",
//              "",
//              "extension Objects {",
//              "    struct \(name): Decodable {"
//            ] + type.fields.map { try generateFieldDecoder(for: $0) }.indent(by: 8) +
//            [ "    }",
//              "}",
//              "",
//              "typealias \(identifier) = Interfaces.\(name)",
//              "",
//              "extension SelectionSet where TypeLock == \(identifier) {"
//            ] + type.fields.flatMap { try generateField($0) }.indent(by: 4) +
//            [ "}" ]
//        
//        return code
//    }
//}
