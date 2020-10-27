import Foundation

extension GraphQLCodegen {
    /// Generates struct that is applicable to input object.
    func generateInputObject(_ name: String, for type: GraphQL.InputObjectType) throws -> [String] {
        try
            [ "struct \(name): Codable, Hashable {"
            ] + type.inputFields.flatMap { try generateInputField($0) }.indent(by: 4) +
            [ "}" ]
    }
    
    // MARK: - Private helpers
    
    /// Generates a single fileld.
    private func generateInputField(_ field: GraphQL.InputValue) throws -> [String] {
        [ generateDescription(for: field),
          "let \(field.name.normalize): \(try generatePropertyType(for: field.type))"
        ]
        .compactMap { $0 }
    }
    
    private func generateDescription(for field: GraphQL.InputValue) -> String? {
        field.description.map { "/// \($0)" }
    }
    
    private func generatePropertyType(for ref: GraphQL.InputTypeRef) throws -> String {
        try generatePropertyType(for: ref.inverted)
    }
    
    private func generatePropertyType(for ref: GraphQL.InvertedInputTypeRef) throws -> String {
        switch ref {
        case .named(let named):
            switch named {
            case .scalar(let scalar):
                return try self.options.scalar(scalar)
            case .enum(let enm):
                return "Enums.\(enm.pascalCase)"
            case .inputObject(let inputObject):
                return inputObject.pascalCase
            }
        case .list(let subref):
            let wrappedType = try generatePropertyType(for: subref)
            return "[\(wrappedType)]"
        case .nullable(let subref):
            let wrappedType = try generatePropertyType(for: subref)
            return "\(wrappedType)?"
        }
    }
    
}
