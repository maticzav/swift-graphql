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
        return gqlEncoding.data.tree!.serialize()
    }
}

// MARK: - Tree Representation

/**
 Internal representation of query data.
 */
fileprivate indirect enum Value {
    case value(String)
    case list([Value])
    case dict([String: Value])
}

extension Value {
    /// Returns a string representation of the values.
    func serialize() -> String {
        switch self {
        case .value(let value):
            return value
        case .list(let values):
            return "[ \(values.map { $0.serialize() }.joined(separator: ", ")) ]"
        case .dict(let dict):
            return "{ \(dict.map { "\($0.key): \($0.value.serialize())" }.joined(separator: ", ")) }"
        }
    }
}

// MARK: - Encoder

fileprivate struct GQLEncoding: Encoder {
    // MARK: - Data
    
    fileprivate final class Data {
        private(set) var tree: Value? = nil
        
        func encode(_ value: Value) {
            self.tree = value
//            switch value {
//            case .value(_):
//                tree = value
//            default:
//                <#code#>
//            }
        }
    }
    
    fileprivate var data: Data = Data()
    
    // MARK: - Properties
    
    var codingPath: [CodingKey] = []
    
    let userInfo = [CodingUserInfoKey : Any]()
    
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

fileprivate struct GQLKeyedEncoding<Key: CodingKey>: KeyedEncodingContainerProtocol {
    private let data: GQLEncoding.Data
    
    init(to data: GQLEncoding.Data) {
        self.data = data
    }
    
    var codingPath: [CodingKey] = []
    
    // MARK: - Scalar Methods
    
    mutating func encodeNil(forKey key: Key) throws {
        data.encode(.value("null"))
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        data.encode(.value("\"\(value.description)\""))
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        data.encode(.value(value.description))
    }
    
    // MARK: - Generic methods
    
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let encoder = GQLEncoding()
        try value.encode(to: encoder)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        var container = GQLKeyedEncoding<NestedKey>(to: data)
        container.codingPath = codingPath
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        var container = GQLUnkeyedEncoding(to: data)
        container.codingPath = codingPath
        return container
    }
    
    mutating func superEncoder() -> Encoder {
        let key = Key(stringValue: "super")!
        return superEncoder(forKey: key)
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        let encoder = GQLEncoding(data: data, codingPath: codingPath)
        return encoder
    }
}

fileprivate struct GQLUnkeyedEncoding: UnkeyedEncodingContainer {
    private let data: GQLEncoding.Data
    
    init(to data: GQLEncoding.Data) {
        self.data = data
    }
    
    var codingPath: [CodingKey] = []
    
    private(set) var count: Int = 0
    
    // MARK: - Scalar Methods
    
    mutating func encodeNil() throws {
        data.encode(.value("null"))
    }
    
    mutating func encode(_ value: Bool) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: String) throws {
        data.encode(.value("\"\(value.description)\""))
    }
    
    mutating func encode(_ value: Double) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Float) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int8) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int16) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int32) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int64) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt8) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt16) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt32) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt64) throws {
        data.encode(.value(value.description))
    }
    
    // MARK: - Generic methods
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let encoder = GQLEncoding(data: data, codingPath: codingPath)
        try value.encode(to: encoder)
    }

    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        var container = GQLKeyedEncoding<NestedKey>(to: data)
        container.codingPath = codingPath
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        var container = GQLUnkeyedEncoding(to: data)
        container.codingPath = codingPath
        return container
    }
    
    mutating func superEncoder() -> Encoder {
        let encoder = GQLEncoding(data: data, codingPath: codingPath)
        return encoder
    }
}

fileprivate struct GQLSingleValueEncoding: SingleValueEncodingContainer {
    private let data: GQLEncoding.Data
    
    init(to data: GQLEncoding.Data) {
        self.data = data
    }
    
    var codingPath: [CodingKey] = []
    
    // MARK: - Methods
    
    mutating func encodeNil() throws {
        data.encode(.value("null"))
    }
    
    mutating func encode(_ value: Bool) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: String) throws {
        data.encode(.value("\"\(value.description)\""))
    }
    
    mutating func encode(_ value: Double) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Float) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int8) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int16) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int32) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: Int64) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt8) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt16) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt32) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode(_ value: UInt64) throws {
        data.encode(.value(value.description))
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let encoder = GQLEncoding(data: data, codingPath: codingPath)
        try value.encode(to: encoder)
    }
    
    
}
