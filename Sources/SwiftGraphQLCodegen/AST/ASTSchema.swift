import Foundation

extension GraphQL {
    
    // MARK: - Schema
    struct Schema: Decodable, Equatable {
        let description: String?
        let types: [NamedType]
        /* Root Types */
        let queryType: Operation
        let mutationType: Operation?
        let subscriptionType: Operation?
    }
    
    // MARK: - Operations
    struct Operation: Codable, Equatable {
        let name: String
    }
}

// MARK: - Methods

extension GraphQL.Schema {
    /// Returns names of the operations in schema.
    var operations: [String] {
        [
            queryType.name,
            mutationType?.name,
            subscriptionType?.name
        ].compactMap { $0 }
    }
    
    // MARK: - Named types
    
    /// Returns object definitions from schema.
    var objects: [GraphQL.ObjectType] {
        types.compactMap {
            switch $0 {
            case .object(let type):
                return type
            default:
                return nil
            }
        }
    }

    /// Returns enumerator definitions in schema.
    var enums: [GraphQL.EnumType] {
        types.compactMap {
            switch $0 {
            case .enum(let type):
                return type
            default:
                return nil
            }
        }
    }

    /// Returns input object definitions from schema.
    var inputObjects: [GraphQL.InputObjectType] {
        types.compactMap {
            switch $0 {
            case .inputObject(let type):
                return type
            default:
                return nil
            }
        }
    }
}
