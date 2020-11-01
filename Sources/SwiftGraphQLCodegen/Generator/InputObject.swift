import Foundation

/*
 InputObjects represent the input values that functions accept.
 
 We map the actual keys to more appropriate Swift fields and reference
 the actual fields using CodingKeys enumerator.
 */

extension GraphQLCodegen {
    /// Generates struct that is applicable to input object.
    func generateInputObject(_ name: String, for type: GraphQL.InputObjectType) throws -> [String] {
        
        /* Code */
        var code = [String]()
        
        code.append("struct \(name): Encodable, Hashable {")
        
        /* Fields */
        code.append(contentsOf:
            try type.inputFields.flatMap { try generateInputField($0) }
                        .indent(by: 4)
        )
        code.append("")
        
        /* Encoder */
        code.append("/* Encoder */".indent(by: 4))
        code.append(contentsOf: generateEncoder(for: type.inputFields).indent(by: 4))
        code.append("")
        
        /* Coding keys */
        code.append("/* CodingKeys */".indent(by: 4))
        code.append(contentsOf: generateCodingKeys(for: type.inputFields).indent(by: 4))
        
        code.append("}")
        
        return code
    }
    
    // MARK: - Private helpers
    
    /// Generates a single fileld.
    private func generateInputField(_ field: GraphQL.InputValue) throws -> [String] {
        switch field.type.inverted {
        case .nullable(_):
            return [
                generateDescription(for: field),
                "var \(field.name.camelCase.normalize): \(try generatePropertyType(for: field.type)) = .absent"
            ]
            .compactMap { $0 }
        default:
            return [
                generateDescription(for: field),
                "var \(field.name.camelCase.normalize): \(try generatePropertyType(for: field.type))"
            ]
            .compactMap { $0 }
        }
    }
    
    private func generateDescription(for field: GraphQL.InputValue) -> String? {
        field.description.map { "/// \($0)" }
    }
    
    func generatePropertyType(for ref: GraphQL.InputTypeRef) throws -> String {
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
                return "InputObjects.\(inputObject.pascalCase)"
            }
        case .list(let subref):
            let wrappedType = try generatePropertyType(for: subref)
            return "[\(wrappedType)]"
        case .nullable(let subref):
            let wrappedType = try generatePropertyType(for: subref)
            return "OptionalArgument<\(wrappedType)>"
        }
    }
    
    /// Generates encoder function for an input object.
    private func generateEncoder(for fields: [GraphQL.InputValue]) -> [String] {
        
        /* Code */
        var code = [String]()
        
        code.append("func encode(to encoder: Encoder) throws {")
        code.append("var container = encoder.container(keyedBy: CodingKeys.self)".indent(by: 4))
        code.append("")
        
        code.append(contentsOf: fields.map {
            let key = $0.name.camelCase
            
            switch $0.type.inverted {
            case .nullable(_):
                // Only encode nullables when they have a value.
                return "if \(key).hasValue { try container.encode(\(key), forKey: .\(key)) }"
            default:
                // Always encode keys that are not optional.
                return "try container.encode(\(key), forKey: .\(key))"
            }
        }.indent(by: 4))
        code.append("}")
        
        return code
    }
    
    /// Generates coding keys enumerator for a particular input object.
    private func generateCodingKeys(for fields: [GraphQL.InputValue]) -> [String] {
        
        /* Code */
        var code = [String]()
        
        code.append("enum CodingKeys: CodingKey {")
        code.append(contentsOf: fields.map {
            "case \($0.name.camelCase.normalize) = \"\($0.name)\""
        }.indent(by: 4))
        code.append("}")
        
        return code
    }
    
}
