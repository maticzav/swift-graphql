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
        
        let operations: [(name: String, type: GraphQL.FullType)] = [
            ("RootQuery", schema.queryType.name),
            ("RootMutation",schema.mutationType?.name),
            ("RootSubscription",schema.subscriptionType?.name)
        ].compactMap { (name, operation) in
            schema.types.first(where: { $0.name == operation }).map { (name, $0) }
        }
        
        let objects: [(name: String, type: GraphQL.FullType)] = schema.objects.map {
            (name: generateObjectTypeLock(for: $0.name), type: $0)
        }
        
        /* Generate the API. */
        let code = """
            import SwiftGraphQL

            // MARK: - Operations
            
            \(operations.map { generateObject($0.name, for: $0.type) }.joined(separator: "\n\n\n"))

            // MARK: - Objects

            \(generatePhantomTypes(for: schema.objects))

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
