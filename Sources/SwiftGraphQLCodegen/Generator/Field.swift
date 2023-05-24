import Foundation
import GraphQLAST
import SwiftGraphQLUtils

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
    
    /// Returns dynamic selection function for every field in the collection.
    func getDynamicSelections(parent: String, context: Context) throws -> String {
        try self.map { try $0.getDynamicSelection(parent: parent, context: context) }
            .joined(separator: "\n")
    }
    
    /// Returns static selection function for every field in the collection.
    func getStaticSelections(for type: ObjectType, context: Context) throws -> String {
        try self.map { try $0.getStaticSelection(for: type, context: context) }.joined(separator: "\n")
    }
}

extension Field {
    
    /// Returns a function that may be used to create dynamic selection (i.e. a special subcase of a type) using SwiftGraphQL.
    func getDynamicSelection(parent: String, context: Context) throws -> String {
        let parameters = try fParameters(context: context)
        let output = try type.dynamicReturnType(context: context)
        
        let code = """
        \(docs)
        \(availability)
        public func \(fName)\(parameters) throws -> \(output) {
            \(self.selection(parent: parent))
            self.__select(field)

            switch self.__state {
            case .decoding:
                \(try self.decoder(parent: parent, context: context))
            case .selecting:
                return \(try type.mock(context: context))
            }
        }
        """
        
        return code
    }
    
    /// Returns a function that may be used to select a single field in the object.
    func getStaticSelection(for type: ObjectType, context: Context) throws -> String {
        let parameters = try fParameters(context: context)
        let typelock = "Objects.\(type.name.pascalCase)"
        let returnType = try self.type.dynamicReturnType(context: context)
        let args = self.args.arguments(field: self, context: context)
        
        let code = """
        \(docs)
        \(availability)
        public static func \(fName)\(parameters) -> Selection<\(returnType), \(typelock)> {
            Selection<\(returnType), \(typelock)> {
                try $0.\(fName)\(args)
            }
        }
        """
        
        return code
    }

    private var docs: String {
        if let description = self.description {
            return description.split(separator: "\n").map { "/// \($0)" }.joined(separator: "\n")
        }
        return ""
    }

    private var availability: String {
        if isDeprecated {
            // NOTE: It's possible that a string contains double-quoted characters in deprecation reason.
            //       http://spec.graphql.org/October2021/#sec-Language.Directives
            let message = deprecationReason?.replacingOccurrences(of: "\"", with: "\\\"") ?? ""
            return "@available(*, deprecated, message: \"\(message)\")"
        }
        return ""
    }

    private var fName: String {
        name.camelCase.normalize
    }

    private func fParameters(context: Context) throws -> String {
        try args.parameters(field: self, context: context, typelock: type.type(for: typelock))
    }

    /// Returns a typelock value for this field.
    private var typelock: String {
        switch type.namedType {
        case let .object(typelock):
            return "Objects.\(typelock.pascalCase)"
        case let .interface(typelock):
            return "Interfaces.\(typelock.pascalCase)"
        case let .union(typelock):
            return "Unions.\(typelock.pascalCase)"
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
    func parameters(field: Field, context: Context, typelock: String) throws -> String {
        // We only return parameters when given scalars. If the function is referencing another type,
        // however, we also generate a generic type and add arguments.
        let params = try map { try $0.parameter(context: context) }.joined(separator: ", ")
        
        switch field.type.namedType {
        case .scalar, .enum:
            return "(\(params))"
        default:
            if isEmpty {
                return "<T>(selection: Selection<T, \(typelock)>)"
            }
            return "<T>(\(params), selection: Selection<T, \(typelock)>)"
        }
    }
    
    /// Returns a one-to-one argument mapping.
    func arguments(field: Field, context: Context) -> String {
        let args = self
            .map { $0.name.camelCase }.map { "\($0): \($0.normalize)" }
            .joined(separator: ", ")
        
        switch field.type.namedType {
        case .scalar, .enum:
            return "(\(args))"
        default:
            if isEmpty {
                return "(selection: selection)"
            }
            return "(\(args), selection: selection)"
        }
    }
}

extension InputValue {
    /// Generates a function parameter for this input value.
    fileprivate func parameter(context: Context) throws -> String {
        "\(name.camelCase.normalize): \(try type.type(scalars: context.scalars)) \(self.default)"
    }

    /// Returns the default value of the parameter.
    private var `default`: String {
        switch type.inverted {
        case .nullable:
            return "= .init()"
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
    func selection(parent: String) -> String {
        switch type.namedType {
        case .scalar, .enum:
            return """
            let field = GraphQLField.leaf(
                 field: \"\(name)\",
                 parent: \"\(parent)\",
                 arguments: [ \(args.arguments) ]
            )
            """
        case .interface, .object, .union:
            return """
            let field = GraphQLField.composite(
                 field: "\(name)",
                 parent: "\(parent)",
                 type: "\(self.type.namedType.name)",
                 arguments: [ \(args.arguments) ],
                 selection: selection.__selection()
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
        #"Argument(name: "\#(name)", type: "\#(type.argument)", value: \#(name.camelCase.normalize))"#
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
    func decoder(parent: String, context: Context) throws -> String {
        let internalType = try self.type.namedType.type(scalars: context.scalars)
        let wrappedType = self.type.type(for: internalType)

        switch self.type.namedType {
        case .scalar, .enum:
            return "return try self.__decode(field: field.alias!) { try \(wrappedType)(from: $0) }"
            
        case .interface, .object, .union:
            return "return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }"
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
    func mock(context: Context) throws -> String {
        switch self.namedType {
        case .scalar(let scalar):
            let type = try context.scalars.scalar(scalar)
            return mock(value: "\(type).mockValue")
        case .enum(let enm):
            return mock(value: "Enums.\(enm.pascalCase).mockValue")
        case .interface, .object, .union:
            return "try selection.__mock()"
        }
    }

    /// Returns a mock value wrapped according to ref.
    private func mock(value: String) -> String {
        self.inverted.mock(value: value)
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
    func dynamicReturnType(context: Context) throws -> String {
        switch namedType {
        case let .scalar(scalar):
            let scalar = try context.scalars.scalar(scalar)
            return type(for: scalar)
        case let .enum(enm):
            return type(for: "Enums.\(enm.pascalCase)")
        case .interface, .object, .union:
            return "T"
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
