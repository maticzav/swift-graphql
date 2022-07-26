import Combine
import Foundation

/// Utility type for describing the exchange processor.
///
/// - NOTE: Even though it may seem like the operation stream (downstream) and result stream (upstream) are separate,
///         we usually map operations to results and preserve the stream.
public typealias ExchangeIO = (AnyPublisher<Operation, Never>) -> AnyPublisher<OperationResult, Never>

/// Exchange is a link in the chain of operation processors.
public protocol Exchange {
    /// Register function receives a stream of operations and the next exchange in the chain
    /// and should return a stream of results.
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: @escaping ExchangeIO
    ) -> AnyPublisher<OperationResult, Never>
}
