import Foundation
import GraphQL
import SwiftGraphQL

// MARK: - Operations

enum Operations {}

extension Objects.Query: GraphQLHttpOperation {
  public static var operation: GraphQLOperationKind { .query }
}

// MARK: - Objects

enum Objects {}

extension Objects {
    struct Query {
        let __typename: TypeName = .query
        
        enum TypeName: String, Codable {
            case query = "Query"
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Query<T> = Selection<T, Objects.Query>
}

extension Fields where TypeLock == Objects.Query {
    func hello() throws -> String {
        let field = GraphQLField.leaf(
            field: "hello",
            parent: "Query",
            arguments: []
        )
        self.__select(field)
        
        switch self.__state {
        case .decoding:
            return try self.__decode(field: field.alias!) { try String(from: $0) }
        case .selecting:
            return String.mockValue
        }
    }
    
    /// Returns a list of characters from the Marvel universe.
    
    func characters<T>(
        pagination: OptionalArgument<InputObjects.Pagination> = .init(),
        selection: Selection<T, [Objects.Character]>
    ) throws -> T {
        let field = GraphQLField.composite(
            field: "characters",
            parent: "Query",
            type: "Character",
            arguments: [Argument(name: "pagination", type: "Pagination", value: pagination)],
            selection: selection.__selection()
        )
        self.__select(field)
        
        switch self.__state {
        case .decoding:
            return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
        case .selecting:
            return try selection.__mock()
        }
    }
}

extension Objects {
    struct Character {
        let __typename: TypeName = .character
        
        enum TypeName: String, Codable {
            case character = "Character"
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Character<T> = Selection<T, Objects.Character>
}

extension Fields where TypeLock == Objects.Character {
    
    func id() throws -> String {
        let field = GraphQLField.leaf(
            field: "id",
            parent: "Character",
            arguments: []
        )
        self.__select(field)
        
        switch self.__state {
        case .decoding:
            return try self.__decode(field: field.alias!) { try String(from: $0) }
        case .selecting:
            return String.mockValue
        }
    }
    
    func name() throws -> String {
        let field = GraphQLField.leaf(
            field: "name",
            parent: "Character",
            arguments: []
        )
        self.__select(field)
        
        switch self.__state {
        case .decoding:
            return try self.__decode(field: field.alias!) { try String(from: $0) }
        case .selecting:
            return String.mockValue
        }
    }
    
    func description() throws -> String {
        let field = GraphQLField.leaf(
            field: "description",
            parent: "Character",
            arguments: []
        )
        self.__select(field)
        
        switch self.__state {
        case .decoding:
            return try self.__decode(field: field.alias!) { try String(from: $0) }
        case .selecting:
            return String.mockValue
        }
    }
}

// MARK: - InputObjects

enum InputObjects {}

extension InputObjects {
    struct Pagination: Encodable, Hashable {
        
        var offset: OptionalArgument<Int> = .init()
        /// Number of items in a list that should be returned.
        /// NOTE: Maximum is 20 items.
        var take: OptionalArgument<Int> = .init()
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if offset.hasValue { try container.encode(offset, forKey: .offset) }
            if take.hasValue { try container.encode(take, forKey: .take) }
        }
        
        enum CodingKeys: String, CodingKey {
            case offset = "offset"
            case take = "take"
        }
    }
}
