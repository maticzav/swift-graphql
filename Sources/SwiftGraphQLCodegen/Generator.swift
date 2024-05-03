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
    
    /// Generates Swift files for the graph selections
    /// - Parameters:
    ///   - schema: The GraphQL schema
    ///   - generateStaticFields: Whether to generate static selections for fields on objects
    ///   - singleFile: Whether to return all the swift code in a single file
    /// - Returns: A list of generated files
    public func generate(schema: Schema, generateStaticFields: Bool, singleFile: Bool = false) throws -> [GeneratedFile] {
        let context = Context(schema: schema, scalars: self.scalars)
        
        let subscription = schema.operations.first { $0.isSubscription }?.type.name
        let objects = schema.objects
        let operations = schema.operations.map { $0.declaration() }

        var files: [GeneratedFile] = []

        let header = """
        // This file was auto-generated using maticzav/swift-graphql. DO NOT EDIT MANUALLY!
        import Foundation
        import GraphQL
        import SwiftGraphQL
        """

        let graphContents = """
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

        func addFile(name: String, contents: String) throws {
            let fileContents: String
            if singleFile {
                fileContents = "\n// MARK: \(name)\n\(contents)"
            } else {
                fileContents = "\(header)\n\n\(contents)"
            }
            let file = GeneratedFile(name: name, contents: try fileContents.format())
            files.append(file)
        }

        try addFile(name: "Graph", contents: graphContents)
        for object in objects {
            var contents = try object.declaration(
                objects: objects,
                context: context,
                alias: object.name != subscription
            )

            if generateStaticFields {
                let staticFieldSelection = try object.statics(context: context)
                contents += "\n\n\(staticFieldSelection)"
            }
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

        if singleFile {
            let fileContent = "\(header)\n\n\(files.map(\.contents).joined(separator: "\n\n"))"
            files = [GeneratedFile(name: "Graph", contents: fileContent)]
        }

        return files
    }
}

public struct GeneratedFile {
    public let name: String
    public let contents: String
}
