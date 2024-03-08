import RxSwiftCombine
import Foundation

/// Utility type for describing the exchange processor.
///
/// - NOTE: Even though it may seem like the operation stream (downstream) and result stream (upstream) are separate,
///         we usually map operations to results and preserve the stream.
public typealias ExchangeIO = (Observable<Operation>) -> Observable<OperationResult>

/// Exchange is a link in the chain of operation processors.
public protocol Exchange {
    /// Register function receives a stream of operations and the next exchange in the chain
    /// and should return a stream of results.
    ///
    /// If exchange creates any new sources, it should make sure that once it receives an operation with the same
    /// ID as the operation of the source and of type `teardown` it clears that source to prevent memory leaks.
    func register(
        client: GraphQLClient,
        operations: Observable<Operation>,
        next: @escaping ExchangeIO
    ) -> Observable<OperationResult>
}
