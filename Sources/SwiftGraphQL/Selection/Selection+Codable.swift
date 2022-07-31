import Foundation
import GraphQL

// MARK: - Decoding

extension Selection {
    
    /// Decodes `data` field of the received response of a GraphQL query execution.
    public func decode(raw: AnyCodable) throws -> T {
        try self.__decode(data: raw)
    }
}

// MARK: - Encoding

extension Selection  {
    
    /// Builds a structure that may be sent to the server for execution.
    public func encode(
        operationName: String? = nil,
        extensions: [String: AnyCodable]? = nil
    ) -> ExecutionArgs where TypeLock: GraphQLOperation {
        let selection = self.__selection()
        let query = selection.serialize(for: TypeLock.operation.rawValue, operationName: operationName)
        
        var variables: [String: AnyCodable] = [:]
        for argument in selection.arguments {
            variables[argument.hash] = argument.value
        }
        
        return ExecutionArgs(
            query: query,
            operationName: operationName,
            variables: variables,
            extensions: extensions
        )
    }
}

// MARK: - Errors

public enum SelectionError: Error {
    /// Payload does not match what selection expected.
    case badpayload
}
