import Foundation
import GraphQLAST

/*
 This file contains publicly accessible functions used to
 generate SwiftGraphQL code.
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
    public func generate(from endpoint: URL) throws -> String {
        let schema = try Schema(from: endpoint)
        let code = try generate(from: schema)
        return code
    }

    /// Generates the code that can be used to define selections.
    func generate(from schema: Schema) throws -> String {
        /* Data */

        // ObjectTypes for operations
        let operations: [(type: ObjectType, operation: Operation)] = [
            (schema.queryType.name.pascalCase, .query),
            (schema.mutationType?.name.pascalCase, .mutation),
            (schema.subscriptionType?.name.pascalCase, .subscription),
        ].compactMap { type, operation in
            schema.objects.first(where: { $0.name == type }).map { ($0, operation) }
        }

        // Object types for all other objects.
        let objects: [ObjectType] = schema.objects

        // Phantom type references
        var types = [NamedType]()
        types.append(contentsOf: schema.objects.map { .object($0) })
        types.append(contentsOf: schema.inputObjects.map { .inputObject($0) })

        /* Code parts. */

        let operationsPart = try operations.map {
            try generateOperation(type: $0.type, operation: $0.operation)
        }

        let objectsPart = try objects.map {
            try generateObject($0)
        }

        let interfacesPart = try schema.interfaces.map {
            try generateInterface($0, with: objects)
        }

        let unionsPart = try schema.unions.map {
            try generateUnion($0, with: objects)
        }

        let enumsPart = schema.enums.map {
            generateEnum($0)
        }

        let inputObjectsPart = try schema.inputObjects.map {
            try generateInputObject($0.name.pascalCase, for: $0)
        }

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
