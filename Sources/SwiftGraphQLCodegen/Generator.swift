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
    ///
    /// - Note: This function does not create a target file. You should make sure file exists beforehand.
    public static func generate(
        _ target: URL,
        from schemaURL: URL
    ) throws {
        let code: String = try self.generate(from: schemaURL)
        try code.write(to: target, atomically: true, encoding: .utf8)
    }
    
    /// Generates the API and returns it to handler.
    public static func generate(from schemaURL: URL) throws -> Data {
        try self.generate(from: schemaURL).data(using: .utf8)!
    }
    
    /// Generates the API and returns it to handler.
    public static func generate(from schemaURL: URL) throws -> String {
        let schema: GraphQL.Schema = try self.downloadFrom(schemaURL)
        return self.generate(from: schema)
    }
}
