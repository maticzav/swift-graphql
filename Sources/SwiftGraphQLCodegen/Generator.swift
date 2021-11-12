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

    /// Generates a target SwiftGraphQL Selection file.
    ///
    /// - parameter from: GraphQL server endpoint.
    public func generate(from endpoint: URL, withHeaders headers: [String: String] = [:]) throws -> String {
        let schema = try Schema(from: endpoint, withHeaders: headers)
        let code = try generate(schema: schema)
        return code
    }

    /// Generates the code that can be used to define selections.
    func generate(schema: Schema) throws -> String {
        let code = """
        // This file was auto-generated using maticzav/swift-graphql. DO NOT EDIT MANUALLY!
        import Foundation
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
