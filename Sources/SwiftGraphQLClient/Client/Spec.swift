import Combine
import Foundation

/// Specifies the minimum requirements of a client to support the execution of queries
/// composed using SwiftGraphQL.
public protocol GraphQLClient {
    
    /// Request to use to perform the operation.
    var request: URLRequest { get }
    
    /// Log a debug message.
    func log(message: String) -> Void
    
    /// Executes an operation by sending it down the exchange pipeline.
    ///
    /// - Returns: A publisher that emits all related exchange results.
    func execute(operation: Operation) -> AnyPublisher<OperationResult, Never>
    
    /// Reexecutes an existing operation and doesn't return anything. Existing
    /// streams are going to receive the update.
    func reexecute(operation: Operation) -> Void
}
