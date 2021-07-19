import Foundation
import GraphQLAST

/*
 InputObjects represent the input values that functions accept.

 We map the actual keys to more appropriate Swift fields and reference
 the actual fields using CodingKeys enumerator.
 */

// MARK: - Struct Definition

extension InputObjectType {
    /// Returns the code that represents a particular InputObjectType in our schema. It contains
    /// an encoder as well as the function used to add values into it.
    func declaration(scalars: ScalarMap) throws -> String {
        """
        extension InputObjects {
            struct \(name): Encodable, Hashable {

            \(try inputFields.map { try $0.declaration(scalars: scalars) }.joined(separator: "\n"))

            \(inputFields.encoder)
            \(inputFields.codingKeys)
            }
        }
        """
    }
}

// MARK: - Fields

/*
 This section contains functions that we use to generate field definitions
 of an input object.
 */

extension InputValue {
    /// Returns a declaration of the input value (i.e. the property definition, docs and default value.
    fileprivate func declaration(scalars: ScalarMap) throws -> String {
        """
        \(docs)
        var \(name.normalize): \(try type.type(scalars: scalars)) \(self.default)
        """
    }

    private var docs: String {
        if let description = self.description {
            return "/// \(description)"
        }
        return ""
    }

    /// The default value if the value is nullable.
    private var `default`: String {
        switch type.inverted {
        case .nullable:
            return " = .absent()"
        default:
            return ""
        }
    }
}

extension InputTypeRef {
    /// Returns an internal type for a given input type ref.
    func type(scalars: ScalarMap) throws -> String {
        try inverted.type(scalars: scalars)
    }
}

extension InvertedInputTypeRef {
    /// Returns an internal type for a given input type ref.
    func type(scalars: ScalarMap) throws -> String {
        switch self {
        case let .named(named):
            switch named {
            case let .scalar(scalar):
                return try scalars.scalar(scalar)
            case let .enum(enm):
                return "Enums.\(enm)"
            case let .inputObject(inputObject):
                return "InputObjects.\(inputObject)"
            }
        case let .list(subref):
            return "[\(try subref.type(scalars: scalars))]"
        case let .nullable(subref):
            return "OptionalArgument<\(try subref.type(scalars: scalars))>"
        }
    }
}

// MARK: - Codable

/*
 This section contains functions that we use to make an input object
 conform to codable protocol.
 */

private extension Collection where Element == InputValue {
    /// Generates encoder function for an input object.
    var encoder: String {
        """
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            \(map { $0.encoder }.joined(separator: "\n"))
        }
        """
    }

    /// Returns a codingkeys enumerator that we can use to create a codable out of our type.
    var codingKeys: String {
        """
        enum CodingKeys: String, CodingKey {
        \(map { $0.codingKey }.joined(separator: "\n"))
        }
        """
    }
}

private extension InputValue {
    /// Returns an encoder for this input value.
    var encoder: String {
        let key = name.normalize

        switch type.inverted {
        case .nullable:
            // Only encode nullables when they have a value.
            return "if \(key).hasValue { try container.encode(\(key), forKey: .\(key)) }"
        default:
            // Always encode keys that are not optional.
            return "try container.encode(\(key), forKey: .\(key))"
        }
    }

    /// Returns a coding key for this input value.
    var codingKey: String {
        "case \(name.normalize) = \"\(name)\""
    }
}
