import Foundation
import GraphQLAST

/*
 This file contains publicly accessible functions used to
 generate SwiftGraphQL code.
 */

public struct GraphQLCodegen {
    
    /// Map of supported scalars.
    private let scalars: ScalarMap

    // MARK: - Initializer

    public init(scalars: ScalarMap) {
        self.scalars = ScalarMap.builtin.merging(
            scalars,
            uniquingKeysWith: { _, override in override }
        )
    }
    
    public struct Output {
        /// Generated API.
        public var code: String
        
        /// List of scalars that weren't considered because they weren't listed as supported ones.
        public var ignoredScalars: [String]
    }

    // MARK: - Methods

    /// Generates a target SwiftGraphQL Selection file.
    ///
    /// - parameter from: GraphQL server endpoint.
    public func generate(from endpoint: URL, withHeaders headers: [String: String] = [:]) throws -> Output {
        let schema = try Schema(from: endpoint, withHeaders: headers)
        let filteredSchema = try schema.filter(with: scalars.supported)
        
        let code = try generate(schema: filteredSchema)
        
        let schemaScalars = try schema.scalars()
        let ignoredScalars: [String] = schemaScalars.filter { !scalars.supported.contains($0) }
        
        return Output(code: code, ignoredScalars: ignoredScalars)
    }

    /// Generates the code that can be used to define selections.
    func generate(schema: Schema) throws -> String {
        let context = Context(schema: schema, scalars: self.scalars)
        
        let subscription = schema.operations.first { $0.isSubscription }?.type.name
        
        // Code Parts
        let operations = schema.operations.map { $0.declaration() }
        let objectDefinitions = try schema.objects.map { object in
            try object.declaration(
                objects: schema.objects,
                context: context,
                alias: object.name != subscription
            )
        }
        
        let staticFieldSelection = try schema.objects.map { object in
            try object.statics(
                context: context,
                alias: object.name == subscription
            )
        }
        
        let interfaceDefinitions = try schema.interfaces.map {
            try $0.declaration(objects: schema.objects, context: context)
        }
        
        let unionDefinitions = try schema.unions.map {
            try $0.declaration(objects: schema.objects, context: context)
        }
        
        let enumDefinitions = schema.enums.map { $0.declaration }
        
        let inputObjectDefinitions = try schema.inputObjects.map {
            try $0.declaration(context: context)
        }
        
        // API
        let code = """
        // This file was auto-generated using maticzav/swift-graphql. DO NOT EDIT MANUALLY!
        import Foundation
        import SwiftGraphQL

        // MARK: - Operations
        enum Operations {}
        \(operations.lines)

        // MARK: - Objects
        enum Objects {}
        \(objectDefinitions.lines)
        \(staticFieldSelection.lines)

        // MARK: - Interfaces
        enum Interfaces {}
        \(interfaceDefinitions.lines)

        // MARK: - Unions
        enum Unions {}
        \(unionDefinitions.lines)

        // MARK: - Enums
        enum Enums {}
        \(enumDefinitions.lines)

        // MARK: - Input Objects
        
        /// Utility pointer to InputObjects.
        typealias Inputs = InputObjects
        
        enum InputObjects {}
        \(inputObjectDefinitions.lines)
        """

        let formatted = try code.format()
        return formatted
    }
}
