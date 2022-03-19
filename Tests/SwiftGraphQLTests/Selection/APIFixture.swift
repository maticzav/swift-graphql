// This file was manually generated and serves as a mock implementation of what the code generator produces.

import Foundation
import SwiftGraphQL

// MARK: - Operations

enum Operations {}
extension Objects.Query: GraphQLHttpOperation {
    static var operation: GraphQLOperationKind { .query }
}

// MARK: - Objects

enum Objects {}

extension Objects {
    struct Query {
        let __typename: TypeName = .query
        let droid: [String: Objects.Droid]
        let droids: [String: [Objects.Droid]]
        let hello: [String: String]

        enum TypeName: String, Codable {
            case query = "Query"
        }
    }
}

extension Objects.Query: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var map = HashMap()
        for codingKey in container.allKeys {
            if codingKey.isTypenameKey { continue }

            let alias = codingKey.stringValue
            let field = GraphQLField.getFieldNameFromAlias(alias)

            switch field {
            case "droids":
                if let value = try container.decode([Objects.Droid]?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "droid":
                if let value = try container.decode(Objects.Droid?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "hello":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unknown key \(field)."
                    )
                )
            }
        }

        droids = map["droids"]
        droid = map["droid"]
        hello = map["hello"]
    }
}

extension Fields where TypeLock == Objects.Query {
    func droid<Type>(id: String, selection: Selection<Type, Objects.Droid?>) throws -> Type {
        let field = GraphQLField.composite(
            field: "droid",
            parent: "Query",
            type: "Droid",
            arguments: [Argument(name: "id", type: "ID!", value: id)],
            selection: selection.__selection()
        )
        __select(field)

        switch __state {
        case let .decoding(data):
            return try selection.__decode(data: data.droid[field.alias!])
        case .mocking:
            return try selection.__mock()
        }
    }

    func droids<Type>(selection: Selection<Type, [Objects.Droid]>) throws -> Type {
        let field = GraphQLField.composite(
            field: "droids",
            parent: "Query",
            type: "Droid",
            arguments: [],
            selection: selection.__selection()
        )
        __select(field)

        switch __state {
        case let .decoding(data):
            if let data = data.droids[field.alias!] {
                return try selection.__decode(data: data)
            }
            throw SelectionError.badpayload
        case .mocking:
            return try selection.__mock()
        }
    }
    
    func hello() throws -> String {
        let field = GraphQLField.leaf(
            field: "hello",
            parent: "Query",
            arguments: []
        )
        __select(field)

        switch __state {
        case let .decoding(data):
            
            if let data = data.hello[field.alias!] {
                return data
            }
            throw SelectionError.badpayload
        case .mocking:
            return String.mockValue
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Query<T> = Selection<T, Objects.Query>
}

extension Objects {
    struct Droid {
        let __typename: TypeName = .droid
        let id: [String: String]
        let name: [String: String]
        let primaryFunction: [String: String]

        enum TypeName: String, Codable {
            case droid = "Droid"
        }
    }
}

extension Objects.Droid: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var map = HashMap()
        for codingKey in container.allKeys {
            if codingKey.isTypenameKey { continue }

            let alias = codingKey.stringValue
            let field = GraphQLField.getFieldNameFromAlias(alias)

            switch field {
            case "primaryFunction":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "id":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "name":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unknown key \(field)."
                    )
                )
            }
        }

        primaryFunction = map["primaryFunction"]
        id = map["id"]
        name = map["name"]
    }
}

extension Fields where TypeLock == Objects.Droid {
    func id() throws -> String {
        let field = GraphQLField.leaf(
            field: "id",
            parent: "Droid",
            arguments: []
        )
        __select(field)

        switch __state {
        case let .decoding(data):
            if let data = data.id[field.alias!] {
                return data
            }
            throw SelectionError.badpayload
        case .mocking:
            return String.mockValue
        }
    }

    func name() throws -> String {
        let field = GraphQLField.leaf(
            field: "name",
            parent: "Droid",
            arguments: []
        )
        __select(field)

        switch __state {
        case let .decoding(data):
            if let data = data.name[field.alias!] {
                return data
            }
            throw SelectionError.badpayload
        case .mocking:
            return String.mockValue
        }
    }

    func primaryFunction() throws -> String {
        let field = GraphQLField.leaf(
            field: "primaryFunction",
            parent: "Droid",
            arguments: []
        )
        __select(field)

        switch __state {
        case let .decoding(data):
            if let data = data.primaryFunction[field.alias!] {
                return data
            }
            throw SelectionError.badpayload
        case .mocking:
            return String.mockValue
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Droid<T> = Selection<T, Objects.Droid>
}
