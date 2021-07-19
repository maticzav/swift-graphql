import Foundation
import GraphQLAST

/*
 Codable is responsible for generating an intermediate type that
 generated code uses to decode the response.

 We first decode the key that references a result and use the type
 engraved in the alias to further decode the result. The result is
 saved into a HashMap structure that groups fields with the same type.
 */

// MARK: - Structure

/*
 This section contains functions that we use to generate the structure
 definition itself.
 */

protocol Structure {
    var fields: [Field] { get }
    var possibleTypes: [ObjectTypeRef] { get }
}

extension Structure {
    /// Returns a list of fields shared between all types in the interface.
    func allFields(objects: [ObjectType]) -> [Field] {
        var shared: [Field] = fields

        for object in objects {
            // Skip object if it's not inside possible types.
            guard possibleTypes.contains(where: { $0.name == object.name }) else { continue }
            // Append fields otherwise.
            for field in object.fields {
                // Make suer fields are unique.
                shared.append(field)
            }
        }

        return shared.unique(by: { $0.name }).sorted(by: {$0.name < $1.name})
    }
}

extension Structure {
    /// Returns a definition of a struct that represents a given structure.
    func `struct`(name: String, objects: [ObjectType], scalars: ScalarMap) throws -> String {
        let typename: String
        if let object = possibleTypes.first, self.possibleTypes.count == 1 {
            typename = "let __typename: TypeName = .\(object.name)"
        } else {
            typename = "let __typename: TypeName"
        }

        let properties = try allFields(objects: objects)
            .sorted(by: { $0.name < $1.name })
            .map { try $0.declaration(scalars: scalars) }
            .lines

        return """
        struct \(name) {
            \(typename)
            \(properties)

            \(possibleTypes.typename)
        }
        """
    }
}

private extension Field {
    /// Return a field variable declaration in the structure.
    func declaration(scalars: ScalarMap) throws -> String {
        let type = try self.type.namedType.type(scalars: scalars)
        let wrappedType = self.type.nonNullable.type(for: type)

        return "let \(name.normalize): [String: \(wrappedType)]"
    }
}

// MARK: - Decoder

/*
 This section contains code that we use to generate the decoder for
 given fields.
 */

extension Collection where Element == Field {
    /// Returns a function definition for decoder initializer.
    func decoder(scalars: ScalarMap, includeTypenameDecoder typename: Bool = false) throws -> String {
        let cases: String = try map { try $0.decoder(scalars: scalars) }
            .joined(separator: "\n")
        let mappings: String = map { "self.\($0.name) = map[\"\($0.name)\"]" }
            .joined(separator: "\n")

        return """
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

            var map = HashMap()
            for codingKey in container.allKeys {
                if codingKey.isTypenameKey { continue }

                let alias = codingKey.stringValue
                let field = GraphQLField.getFieldNameFromAlias(alias)

                switch field {
                \(cases)
                default:
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Unknown key \\(field)."
                        )
                    )
                }
            }

            \(typename ? #"self.__typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: "__typename")!)"# : "")

            \(mappings)
        }
        """
    }
}

private extension Collection where Element == ObjectTypeRef {
    var typename: String {
        let types = map { "case \($0.name.normalize) = \"\($0.name)\"" }
            .joined(separator: "\n")

        return """
        enum TypeName: String, Codable {
        \(types)
        }
        """
    }
}

private extension Field {
    /// Returns a code that we use to decode a field in the response.
    func decoder(scalars: ScalarMap) throws -> String {
        let type = try self.type.namedType.type(scalars: scalars)
        let wrappedType = self.type.nullable.type(for: type)

        return """
        case \"\(name)\":
            if let value = try container.decode(\(wrappedType).self, forKey: codingKey) {
                map.set(key: field, hash: alias, value: value as Any)
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
            return "Enums.\(enm)"
        case let .object(type):
            return "Objects.\(type)"
        case let .interface(type):
            return "Interfaces.\(type)"
        case let .union(type):
            return "Unions.\(type)"
        }
    }
}
