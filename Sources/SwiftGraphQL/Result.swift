import Foundation

public typealias JSONData = [String: Any]

// MARK: - GraphQL Result

public struct GraphQLResult<Type, TypeLock> {
    private let response: Data
    private let selection: Selection<Type, TypeLock>
    
    init(_ response: Data, with selection: Selection<Type, TypeLock>) {
        self.response = response
        self.selection = selection
    }
    
    // MARK: - Calculated properties
    
    public var errors: [GraphQLError]? {
        try! JSONDecoder().decode(GraphQLResponse.self, from: self.response).errors
    }
    
    /// Returns the data from the response.
    public var data: Type? {
        let json = try! JSONSerialization.jsonObject(with: response, options: []) as! JSONData
        return (json["data"]).map { selection.decode(data: $0) }
    }
    
    // MARK: - Response
    
    struct GraphQLResponse: Codable {
        // NOTE: There's no data param as data is decoded using generated type casting.
        let errors: [GraphQLError]?
    }
}

extension GraphQLResult: Equatable where Type: Equatable {
    public static func == (lhs: GraphQLResult<Type, TypeLock>, rhs: GraphQLResult<Type, TypeLock>) -> Bool {
        return lhs.data == rhs.data && lhs.errors == rhs.errors
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
