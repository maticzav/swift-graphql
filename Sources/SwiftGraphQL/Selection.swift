import Foundation

/*
 SwiftGraphQL uses Selection structure to collect data about the
 fields a query should fetch. To do that, it passes around a SelectionSet
 class reference. Generated code later calls `select` method on SelectionSet
 to add a subfield to the selection.
 
 SelectionSet also holds information about the response that the generated
 code uses to populate user-defined models.
 
 Generated code extends Select structure using Phantom types. SelectionSet,
 on the other hand, is final as you can see in the declaration.
 */

public final class SelectionSet<Type, TypeLock> {
    
    // Internal representation of selection.
    private(set) var fields = [GraphQLField]()
    // Internal representation of the response.
    //
    // We use internal definition to prevent public setting.
    private var _response: Response = .fetching
    
    // MARK: - Initializers
    
    init() {}
    
    init(data: TypeLock) {
        /* This initializer is used to decode response into Swift data. */
        self._response = .fetched(data)
    }
    
    // MARK: - Accessors
    
    /// Publically accessible response data.
    ///
    /// - Note: This function should only be used by the generated code.
    public var response: Response {
        _response
    }
    
    // MARK: - Methods
    
    /// Lets generated code add a selection to the selection set.
    ///
    /// - Note: This function should only be used by the generated code.
    public func select(_ field: GraphQLField) {
        self.fields.append(field)
    }
    
    /// Lets generated code add a selection to the selection set.
    ///
    /// - Note: This function should only be used by the generated code.
    public func select(_ fields: [GraphQLField]) {
        self.fields.append(contentsOf: fields)
    }
    
    // MARK: - Response
    
    /*
     Represents a response of the request.
     */
    public enum Response {
        case fetching
        case fetched(TypeLock)
    }
}

// MARK: - SelectionSet Decoder

extension SelectionSet: Decodable where TypeLock: Decodable {
    public convenience init(from decoder: Decoder) throws {
        let data = try TypeLock(from: decoder)
        self.init(data: data)
    }
}

// MARK: - Selection

/// Global type used to wrap the selection.
public struct Selection<Type, TypeLock> {
    
    /* Data */

    private let selectionSet = SelectionSet<Type, TypeLock>()
    // function used to decode data and populate selection
    private var decoder: (SelectionSet<Type, TypeLock>) throws -> Type
    private var mocked: Type // mock data
    
    
    // MARK: - Initializer
    
    public init(decoder: @escaping (SelectionSet<Type, TypeLock>) throws -> Type) {
        /* This initializer populates fields (selection set) and grabs a copy of mocked value. */
        self.decoder = decoder
        self.mocked = try! decoder(selectionSet)
    }
    
    // MARK: - Accessors
    
    /// Returns a list of selected fields.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public var selection: [GraphQLField] {
        self.selectionSet.fields
    }
    
    // MARK: - Methods
    
    /// Decodes JSON response into a return type of the selection set.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public func decode(data: TypeLock) throws -> Type {
        /* Construct a copy of the selection set, and use the new selection set to decode data. */
        let selectionSet = SelectionSet<Type, TypeLock>(data: data)
        let data = try self.decoder(selectionSet)
        return data
    }
    
    /// Mocks the data of a selection.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public func mock() -> Type {
        self.mocked
    }
}

// MARK: - Selection Utility functions

/*
 Utility functins are used for extending selections to nullable types and lists.
 */

extension Selection where TypeLock: Decodable {
    /// Lets you convert a type selection into a list selection.
    public var list: Selection<[Type], [TypeLock]> {
        Selection<[Type], [TypeLock]> { selection in
            /* Selection */
            selection.select(self.selection)
            
            /* Decoder */
            switch selection.response {
            case .fetched(let data):
                return try data.map {
                    try self.decode(data: $0)
                }
            case .fetching:
                return []
            }
        }
    }

    /// Lets you decode nullable values.
    public var nullable: Selection<Type?, TypeLock?> {
        Selection<Type?, TypeLock?> { selection in
            /* Selection */
            selection.select(self.selection)
            
            /* Decoder */
            switch selection.response {
            case .fetched(let data):
                return try data.map { try self.decode(data: $0) }
            case .fetching:
                return nil
            }
        }
    }
    
    /// Lets you decode nullable values into non-null ones.
    public var nonNullOrFail: Selection<Type, TypeLock?> {
        Selection<Type, TypeLock?> { selection in
            /* Selection */
            selection.select(self.selection)
            
            /* Decoder */
            switch selection.response {
            case .fetched(let data):
                if let data = data {
                    return try self.decode(data: data)
                }
                throw SwiftGraphQL.HttpError.badpayload
            case .fetching:
                return self.mock()
            }
        }
    }
}

extension SelectionSet {
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
        case .fetched(let data):
            return try selection.decode(data: data)
        case .fetching:
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
            case .fetched(let data):
                return fn(try self.decode(data: data))
            case .fetching:
                return fn(self.mock())
            }
        }
    }
}
