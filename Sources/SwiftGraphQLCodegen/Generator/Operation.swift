import Foundation
import GraphQLAST

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    func generateOperation(
        type: ObjectType,
        operation: Operation
    ) throws -> [String] {
        let name = type.name.pascalCase

        /* Code */
        var code = [String]()

        code.append("/* \(name) */")
        code.append("")

        /* Operation*/
        operation.availability.map { code.append($0) }
        code.append("extension Objects.\(name): \(operation.type) {")
        code.append("    static var operation: String { \"\(operation.rawValue)\" } ")
        code.append("}")
        code.append("")

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
