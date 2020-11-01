import Foundation
//import SwiftFormat
//import SwiftFormatConfiguration

/*
 We generate all of the code into a single file. The main goal
 is that developers don't have to worry about the generated code - it
 just works.
 
 Having multiple files in Swift source code serves no benefit. We do,
 however, implement namespaces to make it easier to identify parts of the code,
 and prevent naming collisions with the remaining parts of the code.
 */

extension GraphQLCodegen {
    
    
    /// Generates the code that can be used to define selections.
    func generate(from schema: GraphQL.Schema) throws -> String {
        /* Data */
        
        // ObjectTypes for operations
        let operations: [(name: String, type: GraphQL.ObjectType, operation: GraphQLCodegen.Operation)] = [
            ("Query", schema.queryType.name.pascalCase, .query),
            ("Mutation", schema.mutationType?.name.pascalCase,  .mutation),
//            ("RootSubscription",schema.subscriptionType?.name.pascalCase, .subscription)
        ].compactMap { (name, type, operation) in
            schema.objects.first(where: { $0.name == type }).map { (name, $0, operation) }
        }
        
        // Object types for all other objects.
        let objects: [GraphQL.ObjectType] = schema.objects
            .filter { !schema.operations.contains($0.name)}
        
        // Phantom type references
        var types = [GraphQL.NamedType]()
        types.append(contentsOf: schema.objects.map { .object($0) })
        types.append(contentsOf: schema.inputObjects.map { .inputObject($0) })
        
        /* Code parts. */
        
        let operationsPart = try operations.map {
            try generateOperation($0.name, for: $0.type, operation: $0.operation).joined(separator: "\n")
        }.joined(separator: "\n\n\n")
        
        let objectsPart = try objects.map {
            try generateObject($0).joined(separator: "\n")
        }.joined(separator: "\n\n\n")
        
        let interfacesPart = try schema.interfaces.map {
            try generateInterface($0, with: objects).joined(separator: "\n")
        }.joined(separator: "\n\n\n")
        
        let unionsPart = try schema.unions.map {
            try generateUnion($0, with: objects).joined(separator: "\n")
        }.joined(separator: "\n\n\n")
        
        let enumsPart = schema.enums.map {
            generateEnum($0)
                .indent(by: 4)
                .joined(separator: "\n")
        }.joined(separator: "\n\n\n")
        
        let inputObjectsPart = try schema.inputObjects.map {
            try generateInputObject($0.name.pascalCase, for: $0)
                .indent(by: 4)
                .joined(separator: "\n")
        }.joined(separator: "\n\n\n")
        
        /* File. */
        let code = [
            "import SwiftGraphQL",
            "",
            "// MARK: - Operations",
            "",
            "enum Operations {}",
            "",
            operationsPart,
            "",
            "// MARK: - Objects",
            "",
            "enum Objects {}",
            "",
            objectsPart,
            "",
            "// MARK: - Interfaces",
            "",
            "enum Interfaces {}",
            "",
            interfacesPart,
            "",
            "// MARK: - Unions",
            "",
            "enum Unions {}",
            "",
            unionsPart,
            "",
            "// MARK: - Enums",
            "",
            "enum Enums {",
            enumsPart,
            "}",
            "",
            "// MARK: - Input Objects",
            "",
            "enum InputObjects {",
            inputObjectsPart,
            "}"
        ].joined(separator: "\n")
        
        return code
        
//        /* Format the code. */
//        var parsed: String = ""
//
//        let configuration = Configuration()
//        let formatted = SwiftFormatter(configuration: configuration)
//
//        try! formatted.format(source: code, assumingFileURL: nil, to: &parsed)
//
//        /* Return */
//
//        return parsed
    }
}
