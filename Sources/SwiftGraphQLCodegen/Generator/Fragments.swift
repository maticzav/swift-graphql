import Foundation
import GraphQLAST

/*
 We use fragments' selection to support union and interface types.
 */

extension Collection where Element == ObjectTypeRef {
    
    /// Returns a function that may create fragment selection for a type of a given interface or union.
    func selection(name type: String, objects: [ObjectType]) -> String {
        """
        extension Fields where TypeLock == \(type) {
            func on<T>(\(parameters)) throws -> T {
                self.select([\(selection(interface: type))])

                switch self.state {
                case .decoding(let data):
                    switch data.__typename {
                    \(decoders(objects: objects))
                    }
                case .mocking:
                    return try \(mock).mock()
                }
            }
        }
        """
    }

    private var parameters: String {
        map { $0.parameter }.joined(separator: ", ")
    }

    /// Creates a field selection variables for the given interface.
    ///
    /// - parameter interace: The name of the union or interface.
    private func selection(interface: String) -> String {
        map { $0.fragment(interface: interface) }.joined(separator: ",\n")
    }

    /// Functions used to decode response values.
    private func decoders(objects: [ObjectType]) -> String {
        map { $0.decoder(objects: objects) }.lines
    }

    /// Type used to 
    private var mock: String {
        self.first!.namedType.name.camelCase
    }
}

private extension ObjectTypeRef {
    /// Returns a parameter definition for a given type reference.
    var parameter: String {
        "\(namedType.name.camelCase): Selection<T, Objects.\(namedType.name.pascalCase)>"
    }

    /// Returns a SwiftGraphQL Fragment selection.
    func fragment(interface: String) -> String {
        #"GraphQLField.fragment(type: "\#(namedType.name)", interface: "\#(interface)", selection: \#(namedType.name.camelCase).selection())"#
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
