import Foundation
import GraphQLAST

/*
 This file contains publicly accessible functions used to
 generate SwiftGraphQL code.
 */

public struct GraphQLCodegen {
    private let scalars: ScalarMap

    // MARK: - Initializer

    public init(scalars: ScalarMap) {
        self.scalars = ScalarMap.builtin.merging(
            scalars,
            uniquingKeysWith: { _, override in override }
        )
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
        let code = try generate(schema: schema)
        return code
    }

    /// Generates the code that can be used to define selections.
    func generate(schema: Schema) throws -> String {
        let code = """
        import SwiftGraphQL

        // MARK: - Operations
        enum Operations {}
        \(schema.operations.map { $0.declaration() }.lines)

        // MARK: - Objects
        enum Objects {}
        \(try schema.objects.map { try $0.declaration(objects: schema.objects, scalars: scalars) }.lines)

        // MARK: - Interfaces
        enum Interfaces {}
        \(try schema.interfaces.map { try $0.declaration(objects: schema.objects, scalars: scalars) }.lines)

        // MARK: - Unions
        enum Unions {}
        \(try schema.unions.map { try $0.declaration(objects: schema.objects, scalars: scalars) }.lines)

        // MARK: - Enums
        enum Enums {}
        \(schema.enums.map { $0.declaration }.lines)

        // MARK: - Input Objects
        enum InputObjects {}
        \(try schema.inputObjects.map { try $0.declaration(scalars: scalars) }.lines)
        """

        let source = try code.format()
        return source
    }
}
