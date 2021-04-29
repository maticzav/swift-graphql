import Foundation

/*
 SwiftGraphQL uses fields to store the information about the response type
 that the generated code uses to make queries and decode results. It leverages
 phantom types to make sure user may only select fields inside a particular type.
 */

public final class Fields<TypeLock> {
    /// Internal representation of selection.
    private(set) var fields = [GraphQLField]()
    
    /// We use internal definition to prevent public setting.
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

// MARK: - Utilities

extension Fields {
    /// Lets you make a selection inside selection set on the entire field.
    public func selection<T>(_ selection: Selection<T, TypeLock>) throws -> T {
        /* Selection */
        select(selection.selection)

        /* Decoder */
        switch response {
        case let .decoding(data):
            return try selection.decode(data: data)
        case .mocking:
            return selection.mock()
        }
    }
}
