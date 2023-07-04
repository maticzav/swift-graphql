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
    /// - NOTE: AnyCodable is represented as a non-nullable value because it's easier to handle results if we represent `nil` value as `AnyCodable(nil)` value.
    /// Because GraphQL Specification allows the possibility of missing `data` field, we manually decode execution result.
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // NOTE: GraphQL Specification allows the possibility of missing `data` field, but the
        //       code in the library assumes that AnyCodable value is always present.
        //       As a workaround, we manually construct a nil literal using AnyCodable to simplify further processing.
        let data = try container.decodeIfPresent(AnyCodable.self, forKey: .data)
        
        self.data = data ?? AnyCodable.init(nilLiteral: ())
        self.errors = try container.decodeIfPresent([GraphQLError].self, forKey: .errors)
        self.hasNext = try container.decodeIfPresent(Bool.self, forKey: .hasNext)
        self.extensions = try container.decodeIfPresent([String : AnyCodable].self, forKey: .extensions)
    }
}

// MARK: - Extra

/// GraphQL execution result that has decoded data parameter.
public struct DecodedExecutionResult<T> {
    
    /// Result of a successfull execution of a query.
    public var data: T
    
    /// Any errors that occurred during the GraphQL execution of the server.
    public var errors: [GraphQLError]?
    
    /// Optional parameter indicating that there are more values following this one.
    public var hasNext: Bool?
    
    /// Reserved entry for implementors to extend the protocol however they see fit.
    public let extensions: [String: AnyCodable]?
    
    public init(
        data: T,
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

