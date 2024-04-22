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
        let objects = schema.objects
        // Code Parts
        let operations = schema.operations.map { $0.declaration() }
        let objectDefinitions = try objects.map { object in
            try object.declaration(
                objects: objects,
                context: context,
                alias: object.name != subscription
            )
        }
        
        let staticFieldSelection = try objects.map { object in
            try object.statics(context: context)
        }
        
        let interfaceDefinitions = try schema.interfaces.map {
            try $0.declaration(objects: objects, context: context)
        }
        
        let unionDefinitions = try schema.unions.map {
            try $0.declaration(objects: objects, context: context)
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
        public enum Operations {}
        \(operations.lines)

        // MARK: - Objects
        public enum Objects {}
        \(objectDefinitions.lines)
        \(staticFieldSelection.lines)

        // MARK: - Interfaces
        public enum Interfaces {}
        \(interfaceDefinitions.lines)

        // MARK: - Unions
        public enum Unions {}
        \(unionDefinitions.lines)

        // MARK: - Enums
        public enum Enums {}
        \(enumDefinitions.lines)

        // MARK: - Input Objects
        
        /// Utility pointer to InputObjects.
        public typealias Inputs = InputObjects
        
        public enum InputObjects {}
        \(inputObjectDefinitions.lines)
        """

        let formatted = try code.format()
        return formatted
    }
}
