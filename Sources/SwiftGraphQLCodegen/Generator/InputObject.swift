import Foundation

/*
 InputObjects represent the input values that functions accept.

 We map the actual keys to more appropriate Swift fields and reference
 the actual fields using CodingKeys enumerator.
 */

extension GraphQLCodegen {
    /// Generates struct that is applicable to input object.
    func generateInputObject(_ name: String, for type: GraphQL.InputObjectType) throws -> [String] {
        /* Filter recursive fields */
        let inputFields = type.inputFields.filter {
            switch $0.type.inverted {
            case let .named(.inputObject(fieldTypeName)), let .nullable(.named(.inputObject(fieldTypeName))):
                if fieldTypeName.pascalCase == name {
                    print("warning: Field '\(name).\($0.name)' has recursive type and is not supported by SwiftGraphQL")
                    return false
                }
            default: break
            }
            return true
        }

        /* Code */
        var code = [String]()

        code.append("struct \(name): Encodable, Hashable {")

        /* Fields */
        code.append(contentsOf:
            try inputFields.flatMap { try generateInputField($0) }.indent(by: 4)
        )
        code.append("")

        /* Encoder */
        code.append("/* Encoder */".indent(by: 4))
        code.append(contentsOf: generateEncoder(for: inputFields).indent(by: 4))
        code.append("")

        /* Coding keys */
        code.append("/* CodingKeys */".indent(by: 4))
        code.append(contentsOf: generateCodingKeys(for: inputFields).indent(by: 4))

        code.append("}")

        return code
    }

    // MARK: - Private helpers

    /// Generates a single fileld.
    private func generateInputField(_ field: GraphQL.InputValue) throws -> [String] {
        switch field.type.inverted {
        case .nullable:
            return [
                generateDescription(for: field),
                "var \(field.name.camelCase.normalize): \(try generatePropertyType(for: field.type)) = .absent()",
            ]
            .compactMap { $0 }
        default:
            return [
                generateDescription(for: field),
                "var \(field.name.camelCase.normalize): \(try generatePropertyType(for: field.type))",
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
        case let .named(named):
            switch named {
            case let .scalar(scalar):
                return try options.scalar(scalar)
            case let .enum(enm):
                return "Enums.\(enm.pascalCase)"
            case let .inputObject(inputObject):
                return "InputObjects.\(inputObject.pascalCase)"
            }
        case let .list(subref):
            let wrappedType = try generatePropertyType(for: subref)
            return "[\(wrappedType)]"
        case let .nullable(subref):
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
            let key = $0.name.camelCase.normalize

            switch $0.type.inverted {
            case .nullable:
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

        code.append("enum CodingKeys: String, CodingKey {")
        code.append(contentsOf: fields.map {
            "case \($0.name.camelCase.normalize) = \"\($0.name)\""
        }.indent(by: 4))
        code.append("}")

        return code
    }
}
