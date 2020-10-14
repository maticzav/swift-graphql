import Foundation

/// Global type used to select query fields.
public class SelectionSet<Type, TypeLock> {
    private(set) var fields = [GraphQLField]() // selected fields
    private var data: Any? // response data
    
    init() {}
    
    init(data: Any) {
        /* This initializer is used to decode response into Swift data. */
        self.data = data
    }
    
    // MARK: - Accessors
    
    /// Lets generated code read the data.
    ///
    /// - Note: This function should only be used by the generated code.
    public var response: Any? {
        data
    }
    
    // MARK: - Methods
    
    /// Lets generated code add a selection to the selection set.
    ///
    /// - Note: This function should only be used by the generated code.
    public func select(_ field: GraphQLField) {
        self.fields.append(field)
    }
}

/// Global type used to wrap the selection.
public struct Selection<Type, TypeLock> {
    public typealias SelectionDecoder = (SelectionSet<Type, TypeLock>) -> Type
    
    /* Data */

    private let selectionSet = SelectionSet<Type, TypeLock>()
    private var decoder: SelectionDecoder // function used to decode data and populate selection
    private var mocked: Type // mock data
    
    
    // MARK: - Initializer
    
    public init(decoder: @escaping SelectionDecoder) {
        /* This initializer populates fields (selection set) and grabs a copy of mocked value. */
        self.decoder = decoder
        self.mocked = decoder(selectionSet)
    }
    
    // MARK: - Accessors
    
    /// Returns a list of selected fields.
    public var selection: [GraphQLField] {
        self.selectionSet.fields
    }
    
    // MARK: - Methods
    
    /// Decodes JSON response into a return type of the selection set.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public func decode(data: Any) -> Type {
        /* Construct a copy of the selection set, and use the new selection set to decode data. */
        let data = (data as! [String: Any?])
        let selectionSet = SelectionSet<Type, TypeLock>(data: data)
        return self.decoder(selectionSet)
    }
    
    /// Mocks the data of a selection.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public func mock() -> Type {
        self.mocked
    }
}


/* Selection Extension */


extension Selection {
    /// Lets you convert a type selection into a list selection.
    public var list: Selection<[Type], [TypeLock]> {
        return Selection<[Type], [TypeLock]> { selection in
            self.selection.forEach(selection.select)
            
            if let data = selection.response {
                return (data as! [Any]).map { self.decode(data: $0) }
            }
            
            return []
        }
    }

    /// Lets you decode nullable values.
    public var nullable: Selection<Type?, TypeLock?> {
        Selection<Type?, TypeLock?> { selection in
            self.selection.forEach(selection.select)
            
            if let data = selection.response {
                return self.decode(data: data)
            }
            
            return nil
        }
    }
    
    // Lets you leave the selection empty.
    public var empty: Selection<String, TypeLock> {
        Selection<String, TypeLock> { selection in
            let field = GraphQLField.leaf(name: "__typename")
            
            selection.select(field)
            
            if let data = selection.response {
                return (data as! [String: Any])["__typename"] as! String
            }
            
            return "__typename"
        }
    }
}
