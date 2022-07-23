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

/// GraphQL execution result as outlined in the [GraphQL Spec](http://spec.graphql.org/October2021/#sec-Response-Format).
public struct ExecutionResult {
    
    /// Result of a successfull execution of a query.
    public var data: AnyCodable
    
    /// Any errors that occurred during the GraphQL execution of the server.
    public var errors: [GraphQLError]?
    
    /// Optional parameter indicating that there are more values following this one.
    public var hasNext: Bool?
    
    /// Reserved entry for implementors to extend the protocol however they see fit.
    public let extensions: [String: AnyCodable]?
    
    public init(
        data: AnyCodable,
        errors: [GraphQLError]? = nil,
        hasNext: Bool? = nil,
        extensions: [String: AnyCodable]? = nil
    ) {
        self.data = data
        self.errors = errors
        self.hasNext = hasNext
        self.extensions = extensions
    }
}


extension ExecutionResult: Equatable  {}
extension ExecutionResult: Encodable  {}
extension ExecutionResult: Decodable  {}
