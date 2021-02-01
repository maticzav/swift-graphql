import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateOperation(
        _ identifier: String,
        for type: GraphQL.ObjectType,
        operation: Operation
    ) throws -> [String] {
        /* Code */
        var code = [String]()

        code.append("/* \(identifier) */")
        code.append("")

        /* Definition*/
        operation.availability.map { code.append($0) }
        code.append("extension Operations {")
        code.append(contentsOf:
            try generateEncodableStruct(
                identifier,
                fields: type.fields,
                protocols: ["Encodable"]
            )
        )
        code.append("}")
        code.append("")

        /* Operation*/
        operation.availability.map { code.append($0) }
        code.append("extension Operations.\(identifier): \(operation.type) {")
        code.append("    static var operation: String { \"\(operation.rawValue)\" } ")
        code.append("}")
        code.append("")

        /* Decoder */
        operation.availability.map { code.append($0) }
        code.append("extension Operations.\(identifier): Decodable {")
        code.append(contentsOf: try generateDecodableExtension(fields: type.fields))
        code.append("}")
        code.append("")

        /* Fields */
        operation.availability.map { code.append($0) }
        code.append("extension Fields where TypeLock == Operations.\(identifier) {")
        code.append(contentsOf: try type.fields.flatMap { try generateField($0) })
        code.append("}")

        return code
    }

    // MARK: - Private helpers

    enum Operation: String {
        case query
        case mutation
        case subscription

        var availability: String? {
            switch self {
            case .query, .mutation:
                return nil
            case .subscription:
                return "@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)"
            }
        }

        var type: String {
            switch self {
            case .query, .mutation:
                return "GraphQLHttpOperation"
            case .subscription:
                return "GraphQLWebSocketOperation"
            }
        }
    }
}
