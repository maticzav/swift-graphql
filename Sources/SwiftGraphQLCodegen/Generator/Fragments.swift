import Foundation
import GraphQLAST

/*
 We use fragments' selection to support union and interface types.
 */

extension Collection where Element == ObjectTypeRef {
    /// Returns a fragment selection for a given type.
    func selection(name: String, objects: [ObjectType]) -> String {
        """
        extension Fields where TypeLock == \(name) {
            func on<Type>(\(parameters)) throws -> Type {
                self.select([\(selection)])

                switch self.response {
                case .decoding(let data):
                    switch data.__typename {
                    \(decoders(objects: objects))
                    }
                case .mocking:
                    return \(mock).mock()
                }
            }
        }
        """
    }

    private var parameters: String {
        map { $0.parameter }.joined(separator: ", ")
    }

    private var selection: String {
        map { $0.fragment }.joined(separator: ", ")
    }
    
    private func decoders(objects: [ObjectType]) -> String {
        self.map { $0.decoder(objects: objects) }.lines
    }
    
    private var mock: String {
        first!.namedType.name.camelCase
    }
}

private extension ObjectTypeRef {
    /// Returns a parameter definition for a given type reference.
    var parameter: String {
        "\(namedType.name.camelCase): Selection<Type, Objects.\(namedType.name.pascalCase)>"
    }

    /// Returns a SwiftGraphQL Fragment selection.
    var fragment: String {
        "GraphQLField.fragment(type: \"\(namedType.name)\", selection: \(namedType.name.camelCase).selection)"
    }

    /// Returns a decoder for a fragment.
    func decoder(objects: [ObjectType]) -> String {
        let name = namedType.name
        let object = objects.first { $0.name == name }!

        let fields = object.fields
            .sorted(by: { $0.name < $1.name })
            .map {
                let name = $0.name.camelCase
                return "\(name): data.\(name)"
            }
            .joined(separator: ", ")

        return """
        case .\(name.camelCase):
            let data = Objects.\(name.pascalCase)(\(fields))
            return try \(name.camelCase).decode(data: data)
        """
    }
}
