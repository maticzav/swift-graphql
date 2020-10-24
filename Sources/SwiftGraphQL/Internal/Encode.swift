import Foundation

/**
 # Overview
 This is an encoder implementation used to serialize argument values in GraphQL queries.
 It consists of three main parts:
    - The public class GraphQLEncoder;
    - The actual encoder conforming to Encoder protocol;
    - The container types used to encode the values themselves.
 
 ## Notes
 To learn more about how Encoder works in Swift, I recommend reading these articles and files:
    - https://www.mikeash.com/pyblog/friday-qa-2017-07-28-a-binary-coder-for-swift.html
    - https://stackoverflow.com/questions/45169254/custom-swift-encoder-decoder-for-the-strings-resource-format
    - https://github.com/apple/swift/blob/main/stdlib/public/core/Codable.swift
    - https://swiftunboxed.com/stdlib/json-encoder-encodable/
 */


public struct GQLEncoder {
    // MARK: - Public interface
    
    /// Returns a GraphQL query string representation of the value.
    public func encode<T: Encodable>(_ value: T) throws -> String {
        let gqlEncoding = GQLEncoding()
        try value.encode(to: gqlEncoding)
        return gqlEncoding.value.serialize()
    }
}

// MARK: - Tree Representation

/**
 Internal representation of query data.
 */
fileprivate indirect enum Value {
    case value(String)
    case list([Value?])
    case dict([String: Value?])
}

extension Optional where Wrapped == Value {
    // MARK: - Private Helpers
    
//    fileprivate func get(at path: [CodingKey]) throws -> Value? {
//        switch path {
//        case let turns where turns.isEmpty:
//            return self
//        default:
//            let head = path.first!
//            let rest = Array(path.dropFirst())
//
//            switch self {
//            case .value(_):
//                throw ValueError.leaf
//            case .dict(let dict):
//                return try dict[head.stringValue]!.get(at: rest)
//            case .list(let values):
//                if let index = head.intValue {
//                    return try values[index].get(at: rest)
//                }
//                throw ValueError.index
//            }
//        }
//    }
    
    fileprivate mutating func set(_ value: Value?, at path: [CodingKey]) throws {
        switch path {
        /* Top */
        case let turns where turns.isEmpty:
            self = value
        /* Setter */
        case let turns where turns.count == 1:
            let head = path.first!

            switch self {
            case .none:
                if let index = head.intValue, index == 0 {
                    self = .list([value])
                } else {
                    self = .dict([head.stringValue: value])
                }
            case .value(_):
                throw ValueError.exisiting
            case .dict(var dict):
                dict[head.stringValue] = value
                self = .dict(dict)
            case .list(var values):
                if let index = head.intValue {
                    if index < values.count {
                        values[index] = value
                    } else if index == values.count {
                        values.append(value)
                    } else {
                        throw ValueError.index
                    }
                    self = .list(values)
                } else {
                    throw ValueError.index
                }
            }
        /* Recursive */
        default:
            let head = path.first!
            let rest = Array(path.dropFirst())

            switch self {
            case .value(_), .none:
                throw ValueError.leaf
            case .dict(var dict):
                try dict[head.stringValue]?.set(value, at: rest)
                self = .dict(dict)
            case .list(var values):
                if let index = head.intValue {
                    try values[index].set(value, at: rest)
                    self = .list(values)
                } else {
                    throw ValueError.index
                }
            }
        }
    }
}

enum ValueError: Error {
    case leaf
    case index
    case exisiting
}

extension Value {
    /// Returns a string representation of the values.
    func serialize() -> String {
        switch self {
        case .value(let value):
            return value
        case .list(let values):
            return "[ \(values.compactMap { $0.map { $0.serialize() } }.joined(separator: ", ")) ]"
        case .dict(let dict):
            let values = dict.sorted { $0.key < $1.key } .compactMap { (key: String, value: Value?) -> String? in
                if let value = value {
                    return "\(key): \(value.serialize())"
                }
                return nil
            }

            return "{ \(values.joined(separator: ", ")) }"
        }
    }
}

// MARK: - Encoder

fileprivate struct GQLEncoding: Encoder {
    // MARK: - Data
    
    fileprivate final class Data {
        private(set) var tree: Value? = nil
        
        /// Encodes a value at a given path.
        func encode(_ value: Value, at path: [CodingKey]) throws {
            try tree.set(value, at: path)
        }
    }
    
    fileprivate var data: Data = Data()
    
    // MARK: - Initializers
    
    init() {}
    
    init(to data: Data) {
        self.data = data
    }
    
    // MARK: - Properties
    
    var codingPath: [CodingKey] = []
    
    let userInfo = [CodingUserInfoKey : Any]()
    
    var value: Value {
        precondition(self.data.tree != nil, "Found empty value in encoder.")
        return self.data.tree!
    }
    
    // MARK: - Methods
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        var container = GQLKeyedEncoding<Key>(to: data)
        container.codingPath = codingPath
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        var container = GQLUnkeyedEncoding(to: data)
        container.codingPath = codingPath
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        var container = GQLSingleValueEncoding(to: data)
        container.codingPath = codingPath
        return container
    }
    
    
}

// MARK: - Containers

/* Keyed */

fileprivate struct GQLKeyedEncoding<Key: CodingKey>: KeyedEncodingContainerProtocol {
    private let data: GQLEncoding.Data
    
    init(to data: GQLEncoding.Data) {
        self.data = data
    }
    
    var codingPath: [CodingKey] = []
    
    // MARK: - Scalar Methods
    
    mutating func encodeNil(forKey key: Key) throws {
        try data.encode(.value("null"), at: codingPath + [key])
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        try data.encode(.value("\"\(value.description)\""), at: codingPath + [key])
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        try data.encode(.value(value.description), at: codingPath + [key])
    }
    
    // MARK: - Generic method
    
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        var encoder = GQLEncoding(to: data)
        encoder.codingPath = codingPath + [key]
        try value.encode(to: encoder)
    }
    
    // MARK: - Containers
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        /* Allocate */
        let path = codingPath + [key]
        try! data.encode(.dict([:]), at: path)
        /* Container */
        var container = GQLKeyedEncoding<NestedKey>(to: data)
        container.codingPath = path
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        /* Allocate */
        let path = codingPath + [key]
        try! data.encode(.list([]), at: path)
        /* Containers */
        var container = GQLUnkeyedEncoding(to: data)
        container.codingPath = path
        return container
    }
    
    mutating func superEncoder() -> Encoder {
        let key = Key(stringValue: "super")!
        return superEncoder(forKey: key)
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        // MARK: TODO
        var encoder = GQLEncoding(to: data)
        encoder.codingPath = codingPath + [key]
        return encoder
    }
}

/* Unkeyed */

fileprivate struct GQLUnkeyedEncoding: UnkeyedEncodingContainer {
    private let data: GQLEncoding.Data
    
    init(to data: GQLEncoding.Data) {
        self.data = data
    }
    
    var codingPath: [CodingKey] = []
    
    private(set) var count: Int = 0
    
    // MARK: - Private Helepers
    
    private mutating func nextIndexedKey() -> CodingKey {
        let nextCodingKey = IndexedCodingKey(intValue: count)!
        count += 1
        return nextCodingKey
    }
    
    private struct IndexedCodingKey: CodingKey {
        let intValue: Int?
        let stringValue: String

        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = intValue.description
        }

        init?(stringValue: String) {
            return nil
        }
    }
    
    // MARK: - Scalar Methods
    
    mutating func encodeNil() throws {
        try data.encode(.value("null"), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: Bool) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: String) throws {
        try data.encode(.value("\"\(value.description)\""), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: Double) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: Float) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: Int) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: Int8) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: Int16) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: Int32) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: Int64) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: UInt) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: UInt8) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: UInt16) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: UInt32) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    mutating func encode(_ value: UInt64) throws {
        try data.encode(.value(value.description), at: codingPath + [nextIndexedKey()])
    }
    
    // MARK: - Generic methods
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        var encoder = GQLEncoding(to: data)
        encoder.codingPath = codingPath + [nextIndexedKey()]
        try value.encode(to: encoder)
    }

    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        /* Allocate */
        let path = codingPath + [nextIndexedKey()]
        try! data.encode(.dict([:]), at: path)
        /* Container */
        var container = GQLKeyedEncoding<NestedKey>(to: data)
        container.codingPath = path
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        /* Allocate */
        let path = codingPath + [nextIndexedKey()]
        try! data.encode(.list([]), at: path)
        /* Container */
        var container = GQLUnkeyedEncoding(to: data)
        container.codingPath = path
        return container
    }
    
    mutating func superEncoder() -> Encoder {
        // MARK: TODO
        var encoder = GQLEncoding(to: data)
        encoder.codingPath = codingPath
        return encoder
    }
}

/* Single value */

fileprivate struct GQLSingleValueEncoding: SingleValueEncodingContainer {
    private let data: GQLEncoding.Data
    
    init(to data: GQLEncoding.Data) {
        self.data = data
    }
    
    var codingPath: [CodingKey] = []
    
    // MARK: - Methods
    
    mutating func encodeNil() throws {
        try data.encode(.value("null"), at: codingPath)
    }
    
    mutating func encode(_ value: Bool) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: String) throws {
        try data.encode(.value("\"\(value.description)\""), at: codingPath)
    }
    
    mutating func encode(_ value: Double) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: Float) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: Int) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: Int8) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: Int16) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: Int32) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: Int64) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: UInt) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: UInt8) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: UInt16) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: UInt32) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode(_ value: UInt64) throws {
        try data.encode(.value(value.description), at: codingPath)
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        var encoder = GQLEncoding(to: data)
        encoder.codingPath = codingPath
        try value.encode(to: encoder)
    }
    
    
}
