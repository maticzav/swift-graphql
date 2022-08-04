import Foundation
import GraphQLAST

/// Structure that holds methods for SwiftGraphQL query-builder generation.
public struct GraphQLCodegen {
    
    /// Map of supported scalars.
    private let scalars: ScalarMap

    // MARK: - Initializer

    public init(scalars: ScalarMap) {
        self.scalars = scalars
    }

    // MARK: - Methods

    /// Generates a SwiftGraphQL Selection File (i.e. the code that tells how to define selections).
    public func generate(schema: Schema) throws -> String {
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
            try object.statics(context: context)
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
        import GraphQL
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
