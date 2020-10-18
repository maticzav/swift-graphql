import Foundation

/**
 This file contains publicly accessible functions used to generate SwiftGraphQL code.
 */

public struct GraphQLCodegen {
    /// Generates a target GraphQL Swift file.
    ///
    /// - Parameters:
    ///     - target: Target output file path.
    ///     - from: GraphQL server endpoint.
    ///     - onComplete: A function triggered once the generation finishes.
    public static func generate(
        _ target: URL,
        from schemaURL: URL,
        onComplete: @escaping () -> Void = {}
    ) -> Void {
        /* Delegates to the sub function. */
        self.generate(from: schemaURL) { (code: String) in
            /* Write the code to the file system. */
            try! code.write(to: target, atomically: true, encoding: .utf8)
            
            onComplete()
        }
    }
    
    /// Generates the API and returns it to handler.
    public static func generate(from schemaURL: URL, handler: @escaping (Data) -> Void) -> Void {
        self.generate(from: schemaURL) {
            handler($0.data(using: .utf8)!)
        }
    }
    
    /// Generates the API and returns it to handler.
    public static func generate(from schemaURL: URL, handler: @escaping (String) -> Void) -> Void {
        /* Code generator function. */
        func generator(schema: GraphQL.Schema) -> Void {
            let code = self.generate(from: schema)
            handler(code)
        }
        
        /* Download the schema from endpoint. */
        self.downloadFrom(schemaURL, handler: generator)
    }
}


