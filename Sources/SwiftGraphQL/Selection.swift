import Foundation

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
    // Internal representation of the response.
    //
    // We use internal definition to prevent public setting.
    private var _response: Response = .mocking

    // MARK: - Initializers

    init() {}

    init(data: TypeLock) {
        /* This initializer is used to decode response into Swift data. */
        _response = .decoding(data)
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
        fields.append(field)
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
        case mocking
        case decoding(TypeLock)
    }
}

// MARK: - Fields Decoder

extension Fields: Decodable where TypeLock: Decodable {
    public convenience init(from decoder: Decoder) throws {
        let data = try TypeLock(from: decoder)
        self.init(data: data)
    }
}

// MARK: - Selection

/// Global type used to wrap the selection.
public struct Selection<Type, TypeLock> {
    /* Data */

    private let fields = Fields<TypeLock>()
    // function used to decode data and populate selection
    private var decoder: (Fields<TypeLock>) throws -> Type
    private var mocked: Type // mock data

    // MARK: - Initializer

    public init(decoder: @escaping (Fields<TypeLock>) throws -> Type) {
        /* This initializer populates fields (selection set) and grabs a copy of mocked value. */
        self.decoder = decoder
        mocked = try! decoder(fields)
    }

    // MARK: - Accessors

    /// Returns a list of selected fields.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public var selection: [GraphQLField] {
        fields.fields
    }

    // MARK: - Methods

    /// Decodes JSON response into a return type of the selection set.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public func decode(data: TypeLock) throws -> Type {
        /* Construct a copy of the selection set, and use the new selection set to decode data. */
        let fields = Fields<TypeLock>(data: data)
        let data = try decoder(fields)
        return data
    }

    /// Mocks the data of a selection.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public func mock() -> Type {
        mocked
    }
}

extension Selection  {
    /// Builds a payload that can be sent to the server
    public func buildPayload(operationName: String? = nil) -> GraphQLQueryPayload
    where TypeLock: GraphQLOperation {
        return GraphQLQueryPayload(
            selection: self,
            operationType: TypeLock.self,
            operationName: operationName
        )
    }
    
    /// Builds a payload that can be sent to the server
    public func buildPayload<UnwrappedTypeLock>(operationName: String? = nil) -> GraphQLQueryPayload
    where UnwrappedTypeLock: GraphQLOperation, Optional<UnwrappedTypeLock> == TypeLock {
        return GraphQLQueryPayload(
            selection: self,
            operationType: UnwrappedTypeLock.self,
            operationName: operationName
        )
    }
}
