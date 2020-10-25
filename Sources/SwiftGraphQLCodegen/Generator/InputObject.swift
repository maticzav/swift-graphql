import Foundation

extension GraphQLCodegen {
    /// Generates struct that is applicable to input object.
    func generateInputObject(_ name: String, for type: GraphQL.InputObjectType) -> [String] {
        [ "struct \(name): Codable {"
        ] + type.inputFields.flatMap(generateInputField).indent(by: 4) +
        [ "}" ]
    }
    
    // MARK: - Private helpers
    
    /// Generates a single fileld.
    private func generateInputField(_ field: GraphQL.InputValue) -> [String] {
        [ generateDescription(for: field)
        , "let \(field.name): \(generatePropertyType(for: field.type))"
        ]
        .compactMap { $0 }
    }
    
    private func generateDescription(for field: GraphQL.InputValue) -> String? {
        field.description.map { "/// \($0)" }
    }
    
    private func generatePropertyType(for ref: GraphQL.InputTypeRef) -> String {
        generatePropertyType(for: ref.inverted)
    }
    
    private func generatePropertyType(for ref: GraphQL.InvertedInputTypeRef) -> String {
        switch ref {
        case .named(let named):
            switch named {
            case .scalar(let scalar):
                return self.options.scalar(scalar)
            case .enum(let enm):
                return "Enums.\(enm.pascalCase)"
            case .inputObject(let inputObject):
                return inputObject.pascalCase
            }
        case .list(let subref):
            return "[\(generatePropertyType(for: subref))]"
        case .nullable(let subref):
            return "\(generatePropertyType(for: subref))?"
        }
    }
    
}
