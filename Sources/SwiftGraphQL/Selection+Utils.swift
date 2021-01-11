import Foundation

/*
 This file contains utility functions that we generally use when writing queries
 using SwiftGraphQL.
 */

/*
 List modifier makes a selection list-complaint.
 */

extension Selection where TypeLock: Decodable {
    /// Lets you convert a type selection into a list selection.
    public var list: Selection<[Type], [TypeLock]> {
        Selection<[Type], [TypeLock]> { selection in
            /* Selection */
            selection.select(self.selection)
            
            /* Decoder */
            switch selection.response {
            case .decoding(let data):
                return try data.map {
                    try self.decode(data: $0)
                }
            case .mocking:
                return []
            }
        }
    }
}

/*
 Nullability modifier that returns a value when mocked, but accepts
 nullable response from the server.
 */

extension Selection where TypeLock: Decodable {
    /// Lets you decode nullable values.
    public var nullable: Selection<Type?, TypeLock?> {
        Selection<Type?, TypeLock?> { selection in
            /* Selection */
            selection.select(self.selection)
            
            /* Decoder */
            switch selection.response {
            case .decoding(let data):
                return try data.map { try self.decode(data: $0) }
            case .mocking:
                return self.mock()
            }
        }
    }
}

/*
 Nullability utility that lets you make nullable decoder - one that might
 return null - accept null values.
 */

extension Selection where TypeLock: Decodable {
    /// Lets you make a failable (nullable) decoder comply accept nullable values.
    public func optional<T>() -> Selection<Type, TypeLock?> where Type == Optional<T> {
        Selection<Type, TypeLock?> { selection in
            /* Selection */
            selection.select(self.selection)
            
            /* Decoder */
            switch selection.response {
            case .decoding(let data):
                return try data.map { try self.decode(data: $0) }.flatMap { $0 }
            case .mocking:
                return self.mock()
            }
        }
    }
}

/*
 Selection nullability modifier. It makes values nullable, but doesn't let them be null.
 */

extension Selection where TypeLock: Decodable {
    
    /// Lets you decode nullable values into non-null ones.
    public var nonNullOrFail: Selection<Type, TypeLock?> {
        Selection<Type, TypeLock?> { selection in
            /* Selection */
            selection.select(self.selection)
            
            /* Decoder */
            switch selection.response {
            case .decoding(let data):
                if let data = data {
                    return try self.decode(data: data)
                }
                throw SwiftGraphQL.HttpError.badpayload
            case .mocking:
                return self.mock()
            }
        }
    }
}

/*
 Selection mapping functions.
 */

extension Selection where TypeLock: Decodable {
    /// Maps selection's return value into a new value using provided mapping function.
    public func map<MappedType>(_ fn: @escaping (Type) -> MappedType) -> Selection<MappedType, TypeLock> {
        Selection<MappedType, TypeLock> { selection in
            /* Selection */
            selection.select(self.selection)
            
            /* Decoder */
            switch selection.response {
            case .decoding(let data):
                return fn(try self.decode(data: data))
            case .mocking:
                return fn(self.mock())
            }
        }
    }
}

// MARK: - Fields Extensions


extension Fields {
    /// Lets you leave the selection empty.
    public var empty: Selection<(), TypeLock> {
        Selection<(), TypeLock> { selection in
            /* Selection */
            let field = GraphQLField.leaf(name: "__typename", arguments: [])
            selection.select(field)
            
            /* Decoder */
            return ()
        }
    }
    
    /// Lets you make a selection inside selection set on the entire field.
    public func selection<T>(_ selection: Selection<T, TypeLock>) throws -> T {
        /* Selection */
        self.select(selection.selection)
        
        /* Decoder */
        switch self.response {
        case .decoding(let data):
            return try selection.decode(data: data)
        case .mocking:
            return selection.mock()
        }
    }
}

/*
 Helper functions that let you make changes upfront.
 */

extension Selection where TypeLock: Decodable {
    /// Lets you provide non-list selection for list field.
    public static func list<NonListType, NonListTypeLock>(
        _ selection: Selection<NonListType, NonListTypeLock>
    ) -> Selection<Type, TypeLock> where Type == [NonListType], TypeLock == [NonListTypeLock] {
        selection.list
    }
    
    /// Lets you provide non-nullable selection for nullable field.
    public static func nullable<NonNullType, NonNullTypeLock>(
        _ selection: Selection<NonNullType, NonNullTypeLock>
    ) -> Selection<Type, TypeLock> where Type == Optional<NonNullType>, TypeLock == Optional<NonNullTypeLock> {
        selection.nullable
    }
    
    /// Lets you provide non-nullable selection for nullable field and require that it has a value.
    public static func nonNullOrFail<NonNullTypeLock>(
        _ selection: Selection<Type, NonNullTypeLock>
    ) -> Selection<Type, TypeLock> where TypeLock == Optional<NonNullTypeLock> {
        selection.nonNullOrFail
    }
}


