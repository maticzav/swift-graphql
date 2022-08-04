import Foundation
import GraphQLAST
import SwiftGraphQLUtils

extension Collection where Element == ObjectTypeRef {
    
    /// Returns a function that may create fragment selection for a type of a given interface or union.
    ///
    /// - parameter name: Name of the fragment this selection is for.
    /// - parameter objects: List of all objects in the scheama.
    func selection(name type: String, objects: [ObjectType]) -> String {
        """
        extension Fields where TypeLock == \(type) {
            func on<T>(\(parameters)) throws -> T {
                self.__select([\(selection(interface: type))])

                switch self.__state {
                case .decoding(let data):
                    let typename = try self.__decode(field: "__typename") { $0.value as? String }
                    switch typename {
                    \(self.decoders(objects: objects))
                    default:
                        throw ObjectDecodingError.unknownInterfaceType(interface: "\(type)", typename: typename)
                    }
                case .selecting:
                    return try \(mock).__mock()
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
        #"GraphQLField.fragment(type: "\#(namedType.name)", interface: "\#(interface)", selection: \#(namedType.name.camelCase).__selection())"#
    }

    /// Returns a decoder for a fragment.
    ///
    /// - parameter objects: List of all objects that appear in the schema.
    func decoder(objects: [ObjectType]) -> String {
        let name = namedType.name
        return """
        case "\(name)":
            return try \(name.camelCase).__decode(data: data)
        """
    }
}
