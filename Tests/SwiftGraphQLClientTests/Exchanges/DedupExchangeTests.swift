import Combine
import GraphQL
@testable import SwiftGraphQLClient
import XCTest

final class DedupExchangeTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    /// Mock operation that we use in the tests.
    private static let queryOperation = SwiftGraphQLClient.Operation(
        id: "mck-id",
        kind: .query,
        request: URLRequest(url: URL(string: "https://mock.com")!),
        policy: .cacheAndNetwork,
        types: [],
        args: ExecutionArgs(query: "", variables: [:])
    )
    
    /// Mock operation that we use in the tests.
    private static let mutationOperation = SwiftGraphQLClient.Operation(
        id: "mut-id",
        kind: .mutation,
        request: URLRequest(url: URL(string: "https://mock.com")!),
        policy: .cacheAndNetwork,
        types: [],
        args: ExecutionArgs(query: "", variables: [:])
    )
    
    /// Function that executes desired operations in prepared environment
    /// and returns the trace.
    func environment(
        _ fn: (PassthroughSubject<SwiftGraphQLClient.Operation, Never>, PassthroughSubject<SwiftGraphQLClient.OperationResult, Never>) -> Void
    ) -> [String] {
        let operations = PassthroughSubject<SwiftGraphQLClient.Operation, Never>()
        let results = PassthroughSubject<SwiftGraphQLClient.OperationResult, Never>()
        
        let client = MockClient()
        
        var trace: [String] = []
        
        
        let exchange = DedupExchange()
        exchange.register(
            client: client,
            operations: operations.eraseToAnyPublisher()
        ) { ops in
            let downstream = ops
                .handleEvents(receiveOutput: { operation in
                    trace.append("requested: \(operation.id) (\(operation.kind.rawValue))")
                })
                .compactMap({ op in
                    SwiftGraphQLClient.OperationResult?.none
                })
                .eraseToAnyPublisher()
            
            let upstream = downstream
                .merge(with: results.eraseToAnyPublisher())
                .eraseToAnyPublisher()
            
            return upstream
        }
        .sink { result in
            let op = result.operation
            trace.append("resulted: \(op.id) (\(op.kind.rawValue))")
        }
        .store(in: &self.cancellables)
        
        fn(operations, results)
        
        return trace
    }
    
    func testForwardsQueryOperationsCorrectly() throws {
        let trace = environment { operations, results in
            operations.send(DedupExchangeTests.queryOperation)
        }
        
        XCTAssertEqual(trace, [
            "requested: mck-id (query)",
        ])
    }
    
    func testForwardsOnlyNonPendingQueryOperations() throws {
        let trace = environment { operations, results in
            operations.send(DedupExchangeTests.queryOperation)
            operations.send(DedupExchangeTests.queryOperation)
        }
        
        XCTAssertEqual(trace, [
            "requested: mck-id (query)",
        ])
    }
    
    func testForwardsDuplicateQueryOperationsAfterGettingResult() throws {
        let trace = environment { operations, results in
            operations.send(DedupExchangeTests.queryOperation)
            results.send(SwiftGraphQLClient.OperationResult(
                operation: DedupExchangeTests.queryOperation,
                data: nil,
                error: nil,
                stale: false
            ))
            operations.send(DedupExchangeTests.queryOperation)
        }
        
        XCTAssertEqual(trace, [
            "requested: mck-id (query)",
            "resulted: mck-id (query)",
            "requested: mck-id (query)",
        ])
    }
    
    func testForwardsDuplicateQueryOperationsAfterOneWasTornDown() throws {
        let trace = environment { operations, results in
            operations.send(DedupExchangeTests.queryOperation)
            operations.send(DedupExchangeTests.queryOperation.with(kind: .teardown))
            operations.send(DedupExchangeTests.queryOperation)
        }
        
        XCTAssertEqual(trace, [
            "requested: mck-id (query)",
            "requested: mck-id (teardown)",
            "requested: mck-id (query)",
        ])
    }
    
    func testAlwaysForwardsMutationOperationsWithoutDeduplication() throws {
        let trace = environment { operations, results in
            operations.send(DedupExchangeTests.mutationOperation)
            operations.send(DedupExchangeTests.mutationOperation)
        }
        
        XCTAssertEqual(trace, [
            "requested: mut-id (mutation)",
            "requested: mut-id (mutation)",
        ])
    }
}
