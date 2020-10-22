import Foundation

public typealias JSONData = [String: Any]

// MARK: - GraphQL Result

public struct GraphQLResult<Type, TypeLock> {
    private let selection: Selection<Type, TypeLock>
    private let data: TypeLock?
    let errors: [GraphQLError]?
}

extension GraphQLResult: Equatable where Type: Equatable, TypeLock: Decodable {
    public static func == (lhs: GraphQLResult<Type, TypeLock>, rhs: GraphQLResult<Type, TypeLock>) -> Bool {
        return lhs.data == rhs.data && lhs.errors == rhs.errors
    }
}

extension GraphQLResult where TypeLock: Decodable {
    init(_ response: Data, with selection: Selection<Type, TypeLock>) throws {
        self.selection = selection
        
        /* Decode data. */
        let decoder = JSONDecoder()
        let response = try decoder.decode(GraphQLResponse.self, from: response)
        
        self.data = response.data
        self.errors = response.errors
    }
    
    // MARK: - Calculated properties
    public var data: Type? {
        return self.data.map { selection.decode(data: $0) }
    }
    
    // MARK: - Response
    
    struct GraphQLResponse: Decodable {
        let data: TypeLock?
        let errors: [GraphQLError]?
    }
}

// MARK: - GraphQL Error

public struct GraphQLError: Codable, Equatable {
    let message: String
    public let locations: [Location]?
//    public let path: [String]?
    
    public struct Location: Codable, Equatable {
        public let line: Int
        public let column: Int
    }
}
