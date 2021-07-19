import Foundation
import GraphQLAST

/*
 We use functions - selections - to construct a query.

 Each selection function contains a selection part that is responsible for
 telling the Selection about its existance and a decoder part that
 checks for the result and returns it as a function value.

 The last part of the function is a mock value which we use as a placeholder
 of the return value on the first run when we collect the selection.
 */

// MARK: - Function Definition

/*
 This section contains functions that we use to generate the selection
 function itself.
 */

extension Collection where Element == Field {
    /// Returns the functions that represent selection for a given type.
    func selection(scalars: ScalarMap) throws -> String {
        try map { try $0.selection(scalars: scalars) }.joined(separator: "\n")
    }
}

extension Field {
    /// Returns the function that may be used to create selection using SwiftGraphQL.
    func selection(scalars: ScalarMap) throws -> String {
        """
        \(docs)
        \(availability)
        func \(fName)\(try fParameters(scalars: scalars)) throws -> \(try type.returnType(scalars: scalars)) {
            \(selection)
            self.select(field)

            switch self.response {
            case .decoding(let data):
                \(decoder)
            case .mocking:
                return \(try type.mock(scalars: scalars))
            }
        }
        """
    }

    // MARK: - TODO: generate function parameter docs and example!

    private var docs: String {
        if let description = self.description {
            return "/// \(description)"
        }
        return ""
    }

    private var availability: String {
        if isDeprecated {
            let message = deprecationReason ?? ""
            return "@available(*, deprecated, message: \"\(message)\")"
        }
        return ""
    }

    private var fName: String {
        name.normalize
    }

    private func fParameters(scalars: ScalarMap) throws -> String {
        try args.parameters(field: self, scalars: scalars, typelock: type.type(for: typelock))
    }

    /// Returns a typelock value for this field.
    private var typelock: String {
        switch type.namedType {
        case let .object(typelock):
            return "Objects.\(typelock)"
        case let .interface(typelock):
            return "Interfaces.\(typelock)"
        case let .union(typelock):
            return "Unions.\(typelock)"
        default:
            return "<ERROR>"
        }
    }
}

// MARK: - Parameters

/*
 This section contains function used to generate function parameters.
 Some functions here rely on function from InputObject file.
 */

private extension Collection where Element == InputValue {
    /// Returns a function parameter definition.
    func parameters(field: Field, scalars: ScalarMap, typelock: String) throws -> String {
        /*
         We only return parameters when given scalars. If the function is referencing another type,
         however, we also generate a generic type and add arguments.
         */
        switch field.type.namedType {
        case .scalar, .enum:
            return "(\(try parameters(scalars: scalars)))"
        default:
            if isEmpty {
                return "<Type>(selection: Selection<Type, \(typelock)>)"
            }
            return "<Type>(\(try parameters(scalars: scalars)), selection: Selection<Type, \(typelock)>)"
        }
    }

    /// Returns a list of parameters for given input values.
    func parameters(scalars: ScalarMap) throws -> String {
        try map { try $0.parameter(scalars: scalars) }.joined(separator: ", ")
    }
}

extension InputValue {
    /// Generates a function parameter for this input value.
    fileprivate func parameter(scalars: ScalarMap) throws -> String {
        "\(name.normalize): \(try type.type(scalars: scalars)) \(self.default)"
    }

    /// Returns the default value of the parameter.
    private var `default`: String {
        switch type.inverted {
        case .nullable:
            return "= .absent()"
        default:
            return ""
        }
    }
}

// MARK: - Selection

/*
 This section contains function that we use to generate parts of the code
 that tell SwiftGraphQL how to construct the query.
 */

private extension Field {
    /// Generates an internal leaf definition used for composing selection set.
    var selection: String {
        switch type.namedType {
        case .scalar, .enum:
            return """
            let field = GraphQLField.leaf(
                 name: \"\(name)\",
                 arguments: [ \(args.arguments) ]
            )
            """
        case .interface, .object, .union:
            return """
            let field = GraphQLField.composite(
                 name: \"\(name)\",
                 arguments: [ \(args.arguments) ],
                 selection: selection.selection
            )
            """
        }
    }
}

private extension Collection where Element == InputValue {
    /// Returns a list of SwiftGraphQL Argument definitions that SwiftGraphQL accepts to create a GraphQL query.
    var arguments: String {
        map { $0.argument }.joined(separator: ",")
    }
}

private extension InputValue {
    /// Returns a SwiftGraphQL Argument definition for a given input value.
    var argument: String {
        #"Argument(name: "\#(name)", type: "\#(type.argument)", value: \#(name.normalize))"#
    }
}

extension InputTypeRef {
    /// Generates an argument definition that we use to make selection using the client.
    var argument: String {
        /*
         We use this variable recursively on list and null references.
         */
        switch self {
        case let .named(named):
            switch named {
            case let .enum(name), let .inputObject(name), let .scalar(name):
                return name
            }
        case let .list(subref):
            return "[\(subref.argument)]"
        case let .nonNull(subref):
            return "\(subref.argument)!"
        }
    }
}

// MARK: - Decoders

/*
 This section contains functions that we use to generate decoders
 for a selection.
 */

private extension Field {
    /// Returns selection decoder for this field.
    var decoder: String {
        let name = self.name

        switch type.inverted.namedType {
        case .scalar(_), .enum:
            switch type.inverted {
            case .nullable:
                // When decoding a nullable scalar, we just return the value.
                return "return data.\(name)[field.alias!]"
            default:
                // In list value and non-optional scalars we want to make sure that value is present.
                return """
                if let data = data.\(name)[field.alias!] {
                    return data
                }
                throw HttpError.badpayload
                """
            }
        case .interface, .object, .union:
            switch type.inverted {
            case .nullable:
                // When decoding a nullable field we simply pass it down to the decoder.
                return "return try selection.decode(data: data.\(name)[field.alias!])"
            default:
                // When decoding a non-nullable field, we want to make sure that field is present.
                return """
                if let data = data.\(name)[field.alias!] {
                    return try selection.decode(data: data)
                }
                throw HttpError.badpayload
                """
            }
        }
    }
}

// MARK: - Mocking

/*
 This section contains functions that we use to create mock
 values for a given field.
 */

extension OutputTypeRef {
    /// Generates mock data for this output ref.
    func mock(scalars: ScalarMap) throws -> String {
        switch namedType {
        case let .scalar(scalar):
            let type = try scalars.scalar(scalar)
            return mock(value: "\(type).mockValue")
        case let .enum(enm):
            return mock(value: "Enums.\(enm).allCases.first!")
        case .interface, .object, .union:
            return "selection.mock()"
        }
    }

    /// Returns a mock value wrapped according to ref.
    private func mock(value: String) -> String {
        inverted.mock(value: value)
    }
}

extension InvertedOutputTypeRef {
    /// Returns a mock value wrapped according to ref.
    func mock(value: String) -> String {
        switch self {
        case .named:
            return value
        case .list:
            return "[]"
        case .nullable:
            return "nil"
        }
    }
}

// MARK: - Output Types

/*
 This section contains functions that we use to generate return
 types of fields.
 */

private extension OutputTypeRef {
    /// Returns a return type of a referrable type.
    func returnType(scalars: ScalarMap) throws -> String {
        switch namedType {
        case let .scalar(scalar):
            let scalar = try scalars.scalar(scalar)
            return type(for: scalar)
        case let .enum(enm):
            return type(for: "Enums.\(enm)")
        case .interface, .object, .union:
            return "Type"
        }
    }
}

extension TypeRef {
    /// Returns a wrapped instance of a given type respecting the reference.
    func type(for name: String) -> String {
        inverted.type(for: name)
    }
}

extension InvertedTypeRef {
    /// Returns a wrapped instance of a given type respecting the reference.
    func type(for name: String) -> String {
        switch self {
        case .named:
            return name
        case let .list(subref):
            return "[\(subref.type(for: name))]"
        case let .nullable(subref):
            return "\(subref.type(for: name))?"
        }
    }
}
