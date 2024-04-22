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

        var files: [GeneratedFile] = []

        func addFile(name: String, contents: String) throws {
            let fileContents = """
            // This file was auto-generated using maticzav/swift-graphql. DO NOT EDIT MANUALLY!
            import Foundation
            import GraphQL
            import SwiftGraphQL

            \(contents)
            """
            let file = GeneratedFile(name: name, contents: try fileContents.format())
            files.append(file)
        }

        // API
        let graphContents = """
        // MARK: - Operations
        public enum Operations {}
        \(operations.lines)

        public enum Objects {}

        public enum Interfaces {}

        public enum Unions {}

        public enum Enums {}

        /// Utility pointer to InputObjects.
        public typealias Inputs = InputObjects
        
        public enum InputObjects {}
        """

        try addFile(name: "Graph", contents: graphContents)
        for object in objects {
            var contents = try object.declaration(
                objects: objects,
                context: context,
                alias: object.name != subscription
            )

            let staticFieldSelection = try object.statics(context: context)
            contents += "\n\n\(staticFieldSelection)"
            try addFile(name: "Objects/\(object.name)", contents: contents)
        }

        for object in schema.inputObjects {
            let contents = try object.declaration(context: context)
            try addFile(name: "InputObjects/\(object.name)", contents: contents)
        }

        for enumSchema in schema.enums {
            try addFile(name: "Enums/\(enumSchema.name)", contents: enumSchema.declaration)
        }

        for interface in schema.interfaces {
            let contents = try interface.declaration(objects: objects, context: context)
            try addFile(name: "Interfaces/\(interface.name)", contents: contents)
        }

        for union in schema.unions {
            let contents = try union.declaration(objects: objects, context: context)
            try addFile(name: "Unions/\(union.name)", contents: contents)
        }

        return files
    }
}

public struct GeneratedFile {
    public let name: String
    public let contents: String
}
