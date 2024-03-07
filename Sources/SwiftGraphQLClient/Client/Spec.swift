import RxSwiftCombine
import Foundation
import Logging

/// Specifies the minimum requirements of a client to support the execution of queries
/// composed using SwiftGraphQL.
public protocol GraphQLClient {
    
    /// Request to use to perform the operation.
    var request: URLRequest { get }
    
    /// A shared logger instance that may be used to emit information about the client state.
    var logger: Logger { get }
    
    /// Executes an operation by sending it down the exchange pipeline.
    ///
    /// - Returns: A publisher that emits all related exchange results.
    func execute(operation: Operation) -> AnyPublisher<OperationResult, Never>
    
    /// Reexecutes an existing operation and doesn't return anything. Existing
    /// streams are going to receive the update.
    func reexecute(operation: Operation) -> Void
}
