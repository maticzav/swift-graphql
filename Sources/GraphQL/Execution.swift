import Foundation

/// The structure holding parameters for a GraphQL request.
///
/// ExecutionArgs contains fields in the [GraphQL over HTTP spec](https://github.com/graphql/graphql-over-http/blob/main/spec/GraphQLOverHTTP.md#request-parameters) and [GraphQL over WebSocket](https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md#subscribe) spec.
public struct ExecutionArgs: Codable, Equatable {
    
    /// A Document containing GraphQL Operations and Fragments to execute.
    public var query: String
    
    /// The name of the Operation in the Document to execute.
    public var operationName: String?
    
    /// Values for any variables defined by the operation.
    public var variables: [String: AnyCodable]?
    
    /// Reserved entry for implementors to extend the protocol however they see fit.
    public var extensions: [String: AnyCodable]?
    
    public init(
        query: String,
        operationName: String? = nil,
        variables: [String: AnyCodable]? = nil,
        extensions: [String: AnyCodable]? = nil
    ) {
        self.query = query
        self.operationName = operationName
        self.variables = variables
        self.extensions = extensions
    }
}

extension ExecutionArgs: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(query)
        hasher.combine(operationName)
    }
}

/// GraphQL execution result.
/// 
/// Execution result follows [GraphQL Spec](http://spec.graphql.org/October2021/#sec-Response-Format).
public struct ExecutionResult: Equatable, Encodable, Decodable {
    
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
