import Foundation

/// Parameters sent to the GraphQL server for evaluation.
public struct ExecutionArgs: Codable, Equatable {
    
    /// Stringified GraphQL selection.
    public var query: String
    
    /// Variables forwarded to the client in the JSON body.
    public var variables: [String: AnyCodable]
    
    /// Name that should be used to identify the operation.
    public var operationName: String?
    
    public init(
        query: String,
        variables: [String: AnyCodable],
        operationName: String? = nil
    ) {
        self.query = query
        self.variables = variables
        self.operationName = operationName
    }
}

extension ExecutionArgs: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(query)
        hasher.combine(operationName)
    }
}

public struct ExecutionResult {
    
    /// Result of a successfull execution of a query.
    public var data: AnyCodable
    
    /// Any errors that occurred during the GraphQL execution of the server.
    public var errors: [GraphQLError]?
    
    /// Optional parameter indicating that there are more values following this one.
    public var hasNext: Bool?
    
    public init(data: AnyCodable, errors: [GraphQLError]? = nil, hasNext: Bool? = nil) {
        self.data = data
        self.errors = errors
        self.hasNext = hasNext
    }
}


extension ExecutionResult: Equatable  {}
extension ExecutionResult: Encodable  {}
extension ExecutionResult: Decodable  {}
