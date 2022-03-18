import Foundation

/// Parameters sent to the GraphQL server for evaluation.
public struct ExecutionArgs: Codable, Equatable {
    
    /// Stringified GraphQL selection.
    public var query: String
    
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

/// The result of GraphQL execution.
///
/// - NOTE:
///   - `errors` is included when any errors occurred as a non-empty array.
///   - `data` is the result of a successful execution of the query.
///   - `extensions` is reserved for adding non-standard properties.
public struct ExecutionResult<T> {
    public var data: T
    public var errors: [GraphQLError]?
}


extension ExecutionResult: Equatable where T: Equatable {}
extension ExecutionResult: Encodable where T: Encodable {}
extension ExecutionResult: Decodable where T: Decodable {}
