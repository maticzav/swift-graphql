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
        map { $0.decoder(objects: objects) }.lines
    }

    private var mock: String {
        first!.namedType.name
    }
}

private extension ObjectTypeRef {
    /// Returns a parameter definition for a given type reference.
    var parameter: String {
        "\(namedType.name): Selection<Type, Objects.\(namedType.name)>"
    }

    /// Returns a SwiftGraphQL Fragment selection.
    var fragment: String {
        "GraphQLField.fragment(type: \"\(namedType.name)\", selection: \(namedType.name).selection)"
    }

    /// Returns a decoder for a fragment.
    func decoder(objects: [ObjectType]) -> String {
        let name = namedType.name
        let object = objects.first { $0.name == name }!

        let fields = object.fields
            .sorted(by: { $0.name < $1.name })
            .map {
                let name = $0.name
                return "\(name): data.\(name)"
            }
            .joined(separator: ", ")

        return """
        case .\(name):
            let data = Objects.\(name)(\(fields))
            return try \(name).decode(data: data)
        """
    }
}
