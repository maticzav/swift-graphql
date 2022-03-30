import Combine
import Foundation

/// Specifies the minimum requirements of a client to support the execution of queries
/// composed using SwiftGraphQL.
public protocol GraphQLClient {
    
    /// Log a debug message.
    func log(message: String) -> Void
    
    /// Executes an operation by sending it down the exchange pipeline.
    ///
    /// - Returns: A publisher that emits all related exchange results.
    func executeRequestOperation(operation: Operation) -> AnyPublisher<OperationResult, Never>
    
    /// Reexecutes an existing operation and doesn't return anything. Existing
    /// streams are going to receive the update.
    func reexecuteOperation(_ operation: Operation) -> Void
}
