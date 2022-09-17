import Foundation
import GraphQLAST
import SwiftGraphQLUtils


/// Structure protocol outlines anything that might be made codable (e.g. GraphQL Objects, Interfaces and Unions).
///
/// To decode a response we first decode values to an intermediate type. We first decode the key
/// that references a result and use the  engraved in the alias to further decode the result. The result is
/// saved into a HashMap structure that groups fields with the same type.
protocol Structure {
    
    /// Name of the GraphQL type that corresponds to this structure
    var name: String { get }
    
    /// Fields that are shared between all types in the structure.
    var fields: [Field] { get }
    
    /// References to the type those fields may be part of.
    var possibleTypes: [ObjectTypeRef] { get }
}

// MARK: - Decoder

private extension Collection where Element == ObjectTypeRef {
    
    /// Returns an enumerator that we use to decode typename field.
    func typenamesEnum() -> String {
        let types = self
            .map { "case \($0.name.camelCase.normalize) = \"\($0.name)\"" }
            .joined(separator: "\n")

        return """
        public enum TypeName: String, Codable {
        \(types)
        }
        """
    }
}

extension OutputRef {
    
    /// Returns an internal reference to the given output type ref.
    func type(scalars: ScalarMap) throws -> String {
        switch self {
        case let .scalar(scalar):
            return try scalars.scalar(scalar)
        case let .enum(enm):
            return "Enums.\(enm.pascalCase)"
        case let .object(type):
            return "Objects.\(type.pascalCase)"
        case let .interface(type):
            return "Interfaces.\(type.pascalCase)"
        case let .union(type):
            return "Unions.\(type.pascalCase)"
        }
    }
}
