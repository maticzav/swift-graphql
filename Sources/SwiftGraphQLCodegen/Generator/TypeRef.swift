extension GraphQLCodegen {
    /// Returns the type as accessible from the generated file.
    func generateOutputType(ref: GraphQL.OutputRef) throws -> String {
        switch ref {
        /* Scalar, Enumerator */
        case let .scalar(scalar):
            return try options.scalar(scalar)
        case let .enum(enm):
            return "Enums.\(enm.pascalCase)"
        /* Selections */
        case let .object(type):
            return "Objects.\(type.pascalCase)"
        case let .interface(type):
            return "Interfaces.\(type.pascalCase)"
        case let .union(type):
            return "Unions.\(type.pascalCase)"
        }
    }
}
