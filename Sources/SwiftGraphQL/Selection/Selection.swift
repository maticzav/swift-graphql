import Foundation
import GraphQL

/*
 SwiftGraphQL uses Selection structure to collect data about the
 fields a query should fetch. To do that, it passes around a Fields
 class reference. Generated code later calls `select` method on Fields
 to add a subfield to the selection.

 Fields also holds information about the response that the generated
 code uses to populate user-defined models.

 Generated code extends Select structure using Phantom types. Fields,
 on the other hand, is final as you can see in the declaration.
 */

public final class Fields<TypeLock> {
    
    // Internal representation of selection.
    private(set) var fields = [GraphQLField]()
    
    /// State of the selection tells whether we are currently building up the query and mocking the
    /// response values or performing decoding with returned data.
//    @available(*, deprecated, message: "This value should only be used by SwiftGraphQL")
    public private(set) var state: State = .mocking
    
    public enum State {
        case mocking
        case decoding(TypeLock)
        
        /// Tells whether the fields have actual data or not.
        public var isMocking: Bool {
            switch self {
            case .mocking:
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Initializers

    init() {}

    public init(data: TypeLock) {
        /* This initializer is used to decode response into Swift data. */
        state = .decoding(data)
    }

    // MARK: - Selection

    /// Lets generated code add a selection to the selection set.
//    @available(*, deprecated, message: "This method should only be used by SwiftGraphQL")
    public func select(_ field: GraphQLField) {
        fields.append(field)
    }

    /// Lets generated code add a selection to the selection set.
//    @available(*, deprecated, message: "This method should only be used by SwiftGraphQL")
    public func select(_ fields: [GraphQLField]) {
        self.fields.append(contentsOf: fields)
    }
    
    // MARK: - Analysis
    
    /// Returns all types referenced in the fields.
    var types: [String] {
        self.fields.flatMap { $0.types }.unique(by: { $0 })
    }
}

extension Fields: Decodable where TypeLock: Decodable {
    public convenience init(from decoder: Decoder) throws {
        // Fields decoder forwards the JSON decoding part to the
        // typelock and parses the desired result using internal initializer.
        let data = try TypeLock(from: decoder)
        self.init(data: data)
    }
}

// MARK: - Selection

/// Global type used to wrap the selection.
public struct Selection<`Type`, TypeLock> {
    
    /// Function that SwiftGraphQL uses to generate selection and convert received JSON
    /// structure into concrete Swift structure.
    private var decoder: (Fields<TypeLock>) throws -> Type
    
    // MARK: - Initializer

    public init(decoder: @escaping (Fields<TypeLock>) throws -> Type) {
        self.decoder = decoder
    }

    // MARK: - Accessors

    /// Returns a list of selected fields.
//    @available(*, deprecated, message: "This method should only be used by SwiftGraphQL")
    public func selection() -> [GraphQLField] {
        let fields = Fields<TypeLock>()
        
        do {
            _ = try decoder(fields)
        } catch {}
        
        return fields.fields
    }
    
    /// Returns all types referenced in the selection.
    public var types: Set<String> {
        self.selection().map { $0.types }.reduce(Set(), { $0.union($1) })
    }

    // MARK: - Methods

    /// Decodes JSON response into a return type of the selection set.
//    @available(*, deprecated, message: "This method should only be used by SwiftGraphQL")
    public func decode(data: TypeLock) throws -> Type {
        // Construct a copy of the selection set, and use the new selection set to decode data.
        let fields = Fields<TypeLock>(data: data)
        
        let data = try self.decoder(fields)
        return data
    }

    /// Mocks the data of a selection.
//    @available(*, deprecated, message: "This method should only be used by SwiftGraphQL")
    public func mock() throws -> Type {
        let fields = Fields<TypeLock>()
        return try decoder(fields)
    }
}
