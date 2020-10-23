import Foundation

/**
 This file contains publicly accessible functions used to generate SwiftGraphQL code.
 */

public struct GraphQLCodegen {
    let options: Options
    
    public init(options: Options = Options()) {
        self.options = options
    }
    
    // MARK: - Methods
    
    /// Generates a target GraphQL Swift file.
    ///
    /// - Parameters:
    ///     - target: Target output file path.
    ///     - from: GraphQL server endpoint.
    ///     - onComplete: A function triggered once the generation finishes.
    ///
    /// - Note: This function does not create a target file. You should make sure file exists beforehand.
    public func generate(
        _ target: URL,
        from schemaURL: URL
    ) throws {
        let code: String = try self.generate(from: schemaURL)
        try code.write(to: target, atomically: true, encoding: .utf8)
    }
    
    /// Generates the API and returns it to handler.
    public func generate(from schemaURL: URL) throws -> String {
        let schema: GraphQL.Schema = try GraphQLCodegen.downloadFrom(schemaURL)
        return self.generate(from: schema)
    }
    
    /// Generator options.
    ///
    /// - Parameters:
    ///     - scalarMappings: A dicitonary of GraphQL scalar keys and Swift type mappings.
    public struct Options {
        public typealias ScalarMap = [String: String]
        
        let scalarMappings: ScalarMap
        
        public init(scalarMappings: ScalarMap = [:]) {
            let map = builtInScalars.merging(scalarMappings, uniquingKeysWith: { (_, override) in override })
            
            self.scalarMappings = map
        }
        
        // MARK: - Default values
        
        private let builtInScalars: ScalarMap = [
            "ID": "String",
            "String": "String",
            "Int": "Int",
            "Boolean": "Bool",
            "Float": "Double"
        ]
    }
}
