import Foundation

extension GraphQLCodegen {
    /// Generates a function to handle a type.
    static func generateObject(_ typeName: String, for type: GraphQL.FullType) -> String {
        // TODO: add support for all fields!
        let fields = (type.fields ?? []).filter {
            switch $0.type.namedType { // TODO
            case .scalar(let scalar):
                return !scalar.isCustom
            case .object(_), .enumeration(_):
                return true
            default:
                return false
            }
        }
        
        return """
        /* \(type.name) */

        extension SelectionSet where TypeLock == \(typeName) {
        \(fields.map { "    \(generateField($0))" }.joined(separator: "\n\n"))
        }
        """
    }
    
    /// Generates an object type used for aliasing a phantom type.
    static func generateObjectTypeLock(for typeName: String) -> String {
        "\(typeName)Object"
    }
}
