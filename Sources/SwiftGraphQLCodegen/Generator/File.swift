import Foundation
//import SwiftFormat
//import SwiftFormatConfiguration

/**
 This file contains code used to generate SwiftGraphQL selectors.
 */

extension GraphQLCodegen {
    
    
    /// Generates the code that can be used to define selections.
    static func generate(from schema: GraphQL.Schema) -> String {
        /* Data */
        
        // ObjectTypes for operations
        let operations: [(name: String, type: GraphQL.ObjectType)] = [
            ("RootQuery", schema.queryType.name.pascalCase),
            ("RootMutation",schema.mutationType?.name.pascalCase),
            ("RootSubscription",schema.subscriptionType?.name.pascalCase)
        ].compactMap { (name, operation) in
            schema.objects.first(where: { $0.name == operation }).map { (name, $0) }
        }
        
        // Object types for all other objects.
        let objects: [(name: String, type: GraphQL.ObjectType)] = schema.objects
            .filter { !schema.operations.contains($0.name)}
            .map { (name: generateObjectTypeLock(for: $0.name.pascalCase), type: $0) }
        
        // Phantom type references
        var types = [GraphQL.NamedType]()
        types.append(contentsOf: schema.objects.map { .object($0) })
        types.append(contentsOf: schema.inputObjects.map { .inputObject($0) })
        
        /* Generate the API. */
        let code = """
            import SwiftGraphQL

            // MARK: - Operations
            
            \(operations.map { generateObject($0.name, for: $0.type) }.joined(separator: "\n\n\n"))

            // MARK: - Objects

            \(generatePhantomTypes(for: types))

            // MARK: - Selection

            \(objects.map { generateObject($0.name, for: $0.type) }.joined(separator: "\n\n\n"))

            // MARK: - Enums

            \(schema.enums.map { generateEnum($0) }.joined(separator: "\n\n\n"))
            """
        
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
