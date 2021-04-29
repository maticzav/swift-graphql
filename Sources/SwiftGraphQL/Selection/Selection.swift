import Foundation



public protocol Queriable {
    associatedtype TypeLock: Decodable
    
    /// Initializes a particular type using given fields.
    init(fields: Fields<TypeLock>) throws
}

extension Queriable {
    /// Mocks the return value of a selectable.
    public func mock() -> Self {
        let fields = Fields<Self, TypeLock>()
        return self(fields)
    }
    
    /// Decodes JSON response into a return type of the selection set.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public func decode(data: TypeLock) throws -> Type {
        /* Construct a copy of the selection set, and use the new selection set to decode data. */
        let fields = Fields<TypeLock>(data: data)
        let data = try decoder(fields)
        return data
    }
}


// MARK: - Selection


/// Global type used to wrap the selection.
public struct Selection<Type, TypeLock> {
    /* Data */

//    private let fields = Fields<TypeLock>()
    // function used to decode data and populate selection
//    private var decoder: (Fields<TypeLock>) throws -> Type
//    private var mocked: Type // mock data

    // MARK: - Initializer

    public init(decoder: @escaping (Fields<TypeLock>) throws -> Type) {
        /* This initializer populates fields (selection set) and grabs a copy of mocked value. */
        self.decoder = decoder
        mocked = try! decoder(fields)
    }

    // MARK: - Accessors


}
