import Foundation
import GraphQL

/// Fields is a class that selection passes around to collect information about the selection
/// of a query and also aids the decoding process.
public final class Fields<TypeLock> {
    
    // Internal representation of selection.
    private(set) var fields = [GraphQLField]()
    
    /// State of the selection tells whether we are currently building up the query and mocking the
    /// response values or performing decoding with returned data.
    ///
    /// - NOTE: This variable should only be used by the generated code.
    public private(set) var __state: State = .selecting
    
    public enum State {
        
        /// Selection is collection data about the query.
        case selecting
        
        /// Selection is trying to parse the received data into a desired value.
        case decoding(AnyCodable)
        
        /// Tells whether the fields have actual data or not.
        public var isMocking: Bool {
            switch self {
            case .selecting:
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Initializers

    init() {}

    /// Lets you decode response data into Swift structures.
    public init(data: AnyCodable) {
        self.__state = .decoding(data)
    }

    // MARK: - Selection

    /// Lets generated code add a selection to the selection set.
    ///
    /// - NOTE: This function should only be used by the generated code.
    public func __select(_ field: GraphQLField) {
        fields.append(field)
    }

    /// Lets generated code add a selection to the selection set.
    ///
    /// - NOTE: This function should only be used by the generated code!
    public func __select(_ fields: [GraphQLField]) {
        self.fields.append(contentsOf: fields)
    }
    
    // MARK: - Decoding
    
    /// Tries to decode a field from an object selection.
    ///
    /// - NOTE: This function should only be used by the generated code!
    public func __decode<T>(field: String, decoder: (AnyCodable) throws -> T) throws -> T {
        switch self.__state {
        case .decoding(let codable):
            switch codable.value {
            case let dict as [String: Any]:
                // We replce `nil` values with Void AnyCodable values for
                // cleaner protocol declaration.
                return try decoder(AnyCodable(dict[field]))
            default:
                throw ObjectDecodingError.unexpectedObjectType(
                    expected: "Dictionary",
                    received: codable.value
                )
            }
        default:
            throw ObjectDecodingError.decodingWhileSelecting
        }
    }
    
    // MARK: - Analysis
    
    /// Returns all types referenced in the fields.
    var types: [String] {
        self.fields.flatMap { $0.types }.unique(by: { $0 })
    }
}

// MARK: - Selection

/// SwiftGraphQL uses Selection structure to collect data about the
/// fields a query should fetch. To do that, it passes around a Fields
/// class reference. Generated code later calls `select` method on Fields
/// to add a subfield to the selection.
public struct Selection<T, TypeLock> {
    
    /// Function that SwiftGraphQL uses to generate selection and convert received JSON
    /// structure into concrete Swift structure.
    private var decoder: (Fields<TypeLock>) throws -> T
    
    // MARK: - Initializer
    
    public init(decoder: @escaping (Fields<TypeLock>) throws -> T) {
        self.decoder = decoder
    }

    // MARK: - Accessors

    /// Returns a list of selected fields.
    ///
    /// - NOTE: This is an internal function that should only be used by the generated code.
    public func __selection() -> [GraphQLField] {
        let fields = Fields<TypeLock>()
        
        do {
            _ = try decoder(fields)
        } catch {}
        
        return fields.fields
    }
    
    /// Returns all types referenced in the selection.
    public var types: Set<String> {
        self.__selection().map { $0.types }.reduce(Set(), { $0.union($1) })
    }

    // MARK: - Methods

    /// Decodes JSON response into a return type of the selection set.
    ///
    /// - NOTE: This is an internal function that should only be used by the generated code.
    public func __decode(data: AnyCodable) throws -> T {
        // Construct a copy of the selection set, and use the new selection set to decode data.
        let fields = Fields<TypeLock>(data: data)
        
        let data = try self.decoder(fields)
        return data
    }

    /// Mocks the data of a selection.
    ///
    /// - NOTE: This is an internal function that should only be used by the generated code!
    public func __mock() throws -> T {
        let fields = Fields<TypeLock>()
        return try decoder(fields)
    }
}

// MARK: - Error

public enum ObjectDecodingError: Error, Equatable {
    public static func == (lhs: ObjectDecodingError, rhs: ObjectDecodingError) -> Bool {
        switch (lhs, rhs) {
        case (.unexpectedNilValue, .unexpectedNilValue):
            return true
        case (.decodingWhileSelecting, .decodingWhileSelecting):
            return true
        case let (.unknownInterfaceType(interface: lint, typename: ltype), .unknownInterfaceType(interface: rint, typename: rtype)):
            return lint == rint && ltype == rtype
        default:
            return false
        }
    }
    
    
    /// Object expected a given type but received a value of a different type.
    case unexpectedObjectType(expected: String, received: Any)
    
    /// Expected a value but received a nil value.
    case unexpectedNilValue
    
    /// Decoding function has been called during the selection process.
    case decodingWhileSelecting
    
    /// Interface received a type it did not expect.
    case unknownInterfaceType(interface: String, typename: String?)
}
