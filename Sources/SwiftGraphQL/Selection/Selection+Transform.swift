import Foundation
import GraphQL

// MARK: - Selection Transformation

public extension Selection {
    
    /// Lets you convert a type selection into a list selection.
    var list: Selection<[T], [TypeLock]> {
        Selection<[T], [TypeLock]> { fields in
            let selection = self.__selection()
            fields.__select(selection)
            
            switch fields.__state {
            case let .decoding(data):
                switch data.value {
                case let array as [Any]:
                    return try array.map { try self.__decode(data: AnyCodable($0)) }
                default:
                    throw ObjectDecodingError.unexpectedObjectType(expected: "Array", received: data.value)
                }
            case .selecting:
                let item = try self.__mock()
                return [item]
            }
        }
    }
    
    /// Lets you decode nullable values.
    var nullable: Selection<T?, TypeLock?> {
        Selection<T?, TypeLock?> { fields in
            let selection = self.__selection()
            fields.__select(selection)

            switch fields.__state {
            case let .decoding(data):
                switch data.value {
                case is Void, is NSNull:
                    return nil
                default:
                    return try self.__decode(data: data)
                }
            case .selecting:
                return try self.__mock()
            }
        }
    }
    
    /// Lets you decode nullable values into non-null ones.
    var nonNullOrFail: Selection<T, TypeLock?> {
        Selection<T, TypeLock?> { fields in
            let selection = self.__selection()
            fields.__select(selection)
            
            switch fields.__state {
            case let .decoding(data):
                switch data.value {
                case is Void, is NSNull:
                    throw ObjectDecodingError.unexpectedNilValue
                default:
                    return try self.__decode(data: data)
                }
            case .selecting:
                return try self.__mock()
            }
        }
    }
    
    /// Lets you make a failable (nullable) decoder accept nullable values.
    func optional<UnwrappedT>() -> Selection<T, TypeLock?> where T == UnwrappedT? {
        Selection<T, TypeLock?> { fields in
            let selection = self.__selection()
            fields.__select(selection)

            switch fields.__state {
            case let .decoding(data):
                return try Optional(data).map { try self.__decode(data: $0) }.flatMap { $0 }
            case .selecting:
                return try self.__mock()
            }
        }
    }
}

public extension Selection {
    
    /// Maps selection's return value into a new value using provided mapping function.
    func map<MappedType>(_ fn: @escaping (T) -> MappedType) -> Selection<MappedType, TypeLock> {
        Selection<MappedType, TypeLock> { fields in
            let selection = self.__selection()
            fields.__select(selection)

            switch fields.__state {
            case let .decoding(data):
                return fn(try self.__decode(data: data))
            case .selecting:
                return fn(try self.__mock())
            }
        }
    }
}

// MARK: - Fields Extensions

public extension Fields {

    /// Lets you make a selection inside selection set on the entire field.
    func selection<T>(_ selection: Selection<T, TypeLock>) throws -> T {
        self.__select(selection.__selection())

        /* Decoder */
        switch __state {
        case let .decoding(data):
            return try selection.__decode(data: data)
        case .selecting:
            return try selection.__mock()
        }
    }
}

/*
 Helper functions that let you make changes upfront.
 */

public extension Selection {
    
    /// Lets you provide non-list selection for list field.
    static func list<NonListType, NonListTypeLock>(
        _ selection: Selection<NonListType, NonListTypeLock>
    ) -> Selection<T, TypeLock> where T == [NonListType], TypeLock == [NonListTypeLock] {
        selection.list
    }

    /// Lets you provide non-nullable selection for nullable field.
    static func nullable<NonNullType, NonNullTypeLock>(
        _ selection: Selection<NonNullType, NonNullTypeLock>
    ) -> Selection<T, TypeLock> where T == NonNullType?, TypeLock == NonNullTypeLock? {
        selection.nullable
    }
}
