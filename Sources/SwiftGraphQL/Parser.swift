import Foundation

public typealias JSONData = [String: Any?]

// MARK: - GraphQL Response

public struct GraphQLResponse {
    public let data: JSONData?
    public let errors: [GraphQLError]?
    
    // MARK: - Methods
    
    /// Parses the data with given selection.
    public func parse<Type, TypeLock>(
        with selection: Selection<Type, TypeLock>
    ) -> GraphQLResult<Type> {
        /**
            - NOTE: As described in the GraphQL spec, either response contains a set of errors or
                    contains the data. That's why we force unwrap self.errors when there's no data.
         */
        GraphQLResult(
            data: self.data.map { selection.decode(data: $0) },
            errors: self.errors
        )
    }

}

// MARK: - GraphQL Result

public struct GraphQLResult<Type> {
    public let data: Type?
    public let errors: [GraphQLError]?
}

extension GraphQLResult: Equatable where Type: Equatable {}

// MARK: - GraphQL Error

public struct GraphQLError: Codable, Equatable {
    public let message: String
    public let locations: [Location]?
//    public let path: [String]?
    
    public struct Location: Codable, Equatable {
        public let line: Int
        public let column: Int
    }
}
