import Foundation

/*
 This file contains publicly accessible functions used to
 generate SwiftGraphQL code.

 Every function related to the codegeneration should be created under
 GraphQLCodegen namespace.
 */

public struct GraphQLCodegen {
    let options: Options

    // MARK: - Initializer

    public init(options: Options = Options()) {
        self.options = options
    }

    // MARK: - Options

    public struct Options {
        public typealias ScalarMap = [String: String]

        /// Map of scalar GraphQL values and their Swift types.
        private let scalarMap: ScalarMap

        // MARK: - Initializer

        public init(scalarMappings: ScalarMap = [:]) {
            let map = builtInScalars.merging(
                scalarMappings,
                uniquingKeysWith: { _, override in override }
            )

            scalarMap = map
        }

        // MARK: - Methods

        /// Returns the mapped value of the scalar.
        func scalar(_ name: String) throws -> String {
            if let mapping = scalarMap[name] {
                return mapping
            }
            throw GraphQLCodegenError.unknownScalar(name)
        }

        // MARK: - Default values

        private let builtInScalars: ScalarMap = [
            "ID": "String",
            "String": "String",
            "Int": "Int",
            "Boolean": "Bool",
            "Float": "Double",
        ]
    }

    // MARK: - Methods

    /// Generates a target GraphQL Swift file.
    ///
    /// - parameter target: Output file path.
    /// - parameter from: GraphQL server endpoint.
    ///
    /// - note: This function does not create a target file. You should make sure file exists beforehand.
    public func generate(
        _ target: URL,
        from schemaURL: URL
    ) throws {
        let code: String = try generate(from: schemaURL)
        try code.write(to: target, atomically: true, encoding: .utf8)
    }

    /// Generates the API and returns it to handler.
    public func generate(from schemaURL: URL) throws -> String {
        let schema: GraphQL.Schema = try GraphQLCodegen.downloadFrom(schemaURL)
        let code = try generate(from: schema)
        return code
    }

    /// Generates the code that can be used to define selections.
    func generate(from schema: GraphQL.Schema) throws -> String {
        /*
         We generate all of the code into a single file. The main goal
         is that developers don't have to worry about the generated code - it
         just works.

         Having multiple files in Swift source code serves no benefit. We do,
         however, implement namespaces to make it easier to identify parts of the code,
         and prevent naming collisions.
         */

        /* Data */

        // ObjectTypes for operations
        let operations: [(name: String, type: GraphQL.ObjectType, operation: Operation)] = [
            ("Query", schema.queryType.name.pascalCase, .query),
            ("Mutation", schema.mutationType?.name.pascalCase, .mutation),
            ("Subscription", schema.subscriptionType?.name.pascalCase, .subscription),
//            ("RootSubscription",schema.subscriptionType?.name.pascalCase, .subscription)
        ].compactMap { name, type, operation in
            schema.objects.first(where: { $0.name == type }).map { (name, $0, operation) }
        }

        // Object types for all other objects.
        let objects: [GraphQL.ObjectType] = schema.objects
            .filter { !schema.operations.contains($0.name) }

        // Phantom type references
        var types = [GraphQL.NamedType]()
        types.append(contentsOf: schema.objects.map { .object($0) })
        types.append(contentsOf: schema.inputObjects.map { .inputObject($0) })

        /* Code parts. */

        let operationsPart = try operations.map {
            try generateOperation($0.name, for: $0.type, operation: $0.operation).joined(separator: "\n")
        }.joined(separator: "\n\n\n")

        let objectsPart = try objects.map {
            try generateObject($0).joined(separator: "\n")
        }.joined(separator: "\n\n\n")

        let interfacesPart = try schema.interfaces.map {
            try generateInterface($0, with: objects).joined(separator: "\n")
        }.joined(separator: "\n\n\n")

        let unionsPart = try schema.unions.map {
            try generateUnion($0, with: objects).joined(separator: "\n")
        }.joined(separator: "\n\n\n")

        let enumsPart = schema.enums.map {
            generateEnum($0)
                .indent(by: 4)
                .joined(separator: "\n")
        }.joined(separator: "\n\n\n")

        let inputObjectsPart = try schema.inputObjects.map {
            try generateInputObject($0.name.pascalCase, for: $0)
                .indent(by: 4)
                .joined(separator: "\n")
        }.joined(separator: "\n\n\n")

        /* File. */
        let code = [
            "import SwiftGraphQL",
            "",
            "// MARK: - Operations",
            "",
            "enum Operations {}",
            "",
            operationsPart,
            "",
            "// MARK: - Objects",
            "",
            "enum Objects {}",
            "",
            objectsPart,
            "",
            "// MARK: - Interfaces",
            "",
            "enum Interfaces {}",
            "",
            interfacesPart,
            "",
            "// MARK: - Unions",
            "",
            "enum Unions {}",
            "",
            unionsPart,
            "",
            "// MARK: - Enums",
            "",
            "enum Enums {",
            enumsPart,
            "}",
            "",
            "// MARK: - Input Objects",
            "",
            "enum InputObjects {",
            inputObjectsPart,
            "}",
        ].joined(separator: "\n")

        let source = try code.format()
        return source
    }
}

enum GraphQLCodegenError: Error {
    case unknownScalar(String)
}
