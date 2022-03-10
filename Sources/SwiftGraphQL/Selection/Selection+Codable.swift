import Foundation
import GraphQL

// MARK: - Decoding

extension Selection where TypeLock: Decodable {
    
    /// Decodes received data into selected type.
    public func decode(_ raw: Data) throws -> (data: Type, errors: [GraphQLError]?) {
        let decoder = JSONDecoder()
        let res = try decoder.decode(ExecutionResult<TypeLock>.self, from: raw)
        
        let parsed = try self.decode(data: res.data)
        return (parsed, res.errors)
    }
}

// MARK: - Encoding

extension Selection  {
    
    /// Builds a structure that may be sent to the server for execution.
    public func encode(operationName: String? = nil) -> ExecutionArgs where TypeLock: GraphQLOperation {
        let selection = self.selection()
        let query = selection.serialize(for: TypeLock.operation, operationName: operationName)
        
        var variables: [String: AnyCodable] = [:]
        for argument in selection.arguments {
            variables[argument.hash] = argument.value
        }
        
        return ExecutionArgs(query: query, variables: variables, operationName: operationName)
    }
    
    /// Builds a structure that may be sent to the server for execution for an optional selected type.
    public func encode<UnwrappedTypeLock>(operationName: String? = nil) -> ExecutionArgs where UnwrappedTypeLock: GraphQLOperation, Optional<UnwrappedTypeLock> == TypeLock {
        let selection = self.selection()
        let query = selection.serialize(for: UnwrappedTypeLock.operation, operationName: operationName)
        
        var variables: [String: AnyCodable] = [:]
        for argument in selection.arguments {
            variables[argument.hash] = argument.value
        }
        
        return ExecutionArgs(query: query, variables: variables, operationName: operationName)
    }
}

// MARK: - Errors

public enum SelectionError: Error {
    /// Payload does not match what selection expected.
    case badpayload
}
