import Foundation

/// A GraphQLError describes an Error found during the parse, validate, or execute phases of performing a GraphQL operation. In addition to a message and stack trace, it also includes information about the locations in a GraphQL document and/or execution result that correspond to the Error.
///
/// Its implementation follows the specification described at [GraphQLSpec](http://spec.graphql.org/October2021/#sec-Errors.Error-result-format).
public struct GraphQLError: Codable, Equatable {
    
    /// A short, human-readable summary of the problem.
    public let message: String
    
    /// Errors during validation often contain multiple locations, for example to point out two things with
    /// the same name. Errors during execution include a single location, the field which
    /// produced the error.
    public let locations: [Location]?
    
    /// Represents a location in a GraphQL source.
    public struct Location: Codable, Equatable, Sendable {
        public let line: Int
        public let column: Int
        
        public init(line: Int, column: Int) {
            self.line = line
            self.column = column
        }
    }
    
    /// Path to the field where error occurred.
    public let path: [PathLink]?
    
    /// An enum representing a path to the field in the GraphQL schema.
    /// - NOTE: Path may present a path descending or a postition in an array.
    ///         That's why path is represented as an enumerator.
    public enum PathLink: Codable, Equatable, Sendable {
        case path(String)
        case index(Int)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let index = try? container.decode(Int.self) {
                self = .index(index)
            } else if let path = try? container.decode(String.self) {
                self = .path(path)
            } else {
                throw GraphQLParsingError.invalidPath
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch self {
            case .path(let path):
                try container.encode(path)
            case .index(let index):
                try container.encode(index)
            }
        }
    }
    
    /// A map of strings for implementors to add additional information to errors however they see fit, and there are no additional restrictions on its contents.
    public let extensions: [String: AnyCodable]?
    
    // MARK: - Initializer

    public init(
        message: String,
        locations: [Location]? = nil,
        path: [PathLink]? = nil,
        extensions: [String: AnyCodable]? = nil
    ) {
        self.message = message
        self.locations = locations
        self.path = path
        self.extensions = extensions
    }
}

enum GraphQLParsingError: Error {
    case invalidPath
}
