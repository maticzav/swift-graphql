extension GraphQLCodegen {
    /// Returns the type as accessible from the generated file.
    func generateOutputType(ref: GraphQL.OutputRef) throws -> String {
        switch ref {
        /* Scalar, Enumerator */
        case .scalar(let scalar):
            return try options.scalar(scalar)
        case .enum(let enm):
            return "Enums.\(enm.pascalCase)"
        /* Selections */
        case .object(let type):
            return "Objects.\(type.pascalCase)"
        case .interface(let type):
            return "Interfaces.\(type.pascalCase)"
        case .union(let type):
            return "Unions.\(type.pascalCase)"
        }
    }
}
