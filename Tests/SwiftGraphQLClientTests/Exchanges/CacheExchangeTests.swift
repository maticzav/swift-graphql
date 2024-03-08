import RxSwiftCombine
import GraphQL
import Foundation
@testable import SwiftGraphQLClient
import XCTest

final class CacheExchangeTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Function that executes desired operations in prepared environment and returns the trace.
    func environment(
        _ fn: (PassthroughSubject<SwiftGraphQLClient.Operation, Never>, PassthroughSubject<SwiftGraphQLClient.OperationResult, Never>) -> Void
    ) -> [String] {
        var trace: [String] = []
        
        let operations = PassthroughSubject<SwiftGraphQLClient.Operation, Never>()
        let results = PassthroughSubject<SwiftGraphQLClient.OperationResult, Never>()
        
        let client = MockClient(customReexecute:  { operation in
            trace.append("reexecuted: \(operation.id) (\(operation.kind.rawValue), \(operation.policy.rawValue))")
        })
        
        
        let exchange = CacheExchange()
        exchange.register(
            client: client,
            operations: operations
                .do(onNext: { operation in
                    trace.append("requested: \(operation.id) (\(operation.kind.rawValue), \(operation.policy.rawValue))")
                })
                .eraseToAnyPublisher()
        ) { ops in
            let downstream = ops
                .do(onNext: { operation in
                    trace.append("forwarded: \(operation.id) (\(operation.kind.rawValue), \(operation.policy.rawValue))")
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
        .subscribe(onNext: { result in
            let op = result.operation
            let stale = result.stale ?? false
            let value = result.data
            
            trace.append("resulted (\(stale)): \(op.id) \(value) (\(op.kind.rawValue))")
        })
        .store(in: &self.cancellables)
        
        fn(operations, results)
        
        return trace
    }
    
    /// Mock operation that we use in the tests.
    private static let queryOperation = SwiftGraphQLClient.Operation(
        id: "qur-id",
        kind: .query,
        request: URLRequest(url: URL(string: "https://mock.com")!),
        policy: .cacheAndNetwork,
        types: ["A", "B", "C"],
        args: ExecutionArgs(query: "", variables: [:])
    )
       /// Mock operation that we use in the tests.
    private static let mutationOperation = SwiftGraphQLClient.Operation(
        id: "mut-id",
        kind: .mutation,
        request: URLRequest(url: URL(string: "https://mock.com")!),
        policy: .cacheAndNetwork,
        types: ["A", "B"],
        args: ExecutionArgs(query: "", variables: [:])
    )
    
       /// Mock operation that we use in the tests.
    private static let subscriptionOperation = SwiftGraphQLClient.Operation(
        id: "sub-id",
        kind: .subscription,
        request: URLRequest(url: URL(string: "https://mock.com")!),
        policy: .cacheAndNetwork,
        types: ["A", "B"],
        args: ExecutionArgs(query: "", variables: [:])
    )
    
    // MARK: - On Query
    
    func testOnQueryCacheFirstHitDoesNotForwardRequest() throws {
        let trace = environment { operations, results in
            operations.send(CacheExchangeTests.queryOperation.with(policy: .cacheFirst))
            operations.send(CacheExchangeTests.queryOperation.with(policy: .cacheFirst))
        }
        
        XCTAssertEqual(trace, [
            "requested: qur-id (query, cache-first)",
            "forwarded: qur-id (query, cache-first)",
            "requested: qur-id (query, cache-first)",
            "forwarded: qur-id (query, cache-first)",
        ])
    }
    
    func testOnQueryCacheFirstForwardsMissingRequest() throws {
        let trace = environment { operations, results in
            let op = CacheExchangeTests.queryOperation.with(policy: .cacheFirst)
            
            operations.send(op)
            results.send(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("hello"),
                error: nil,
                stale: false
            ))
            operations.send(op)
        }
        
        XCTAssertEqual(trace, [
            "requested: qur-id (query, cache-first)",
            "forwarded: qur-id (query, cache-first)",
            "resulted (false): qur-id hello (query)",
            "requested: qur-id (query, cache-first)",
            "resulted (false): qur-id hello (query)",
        ])
    }
    
    func testCacheAndNetworkForwardsRequest() throws {
        let trace = environment { operations, results in
            let op = CacheExchangeTests.queryOperation.with(policy: .cacheAndNetwork)
            
            operations.send(op)
            results.send(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("hello"),
                error: nil,
                stale: false
            ))
            operations.send(op)
            results.send(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("world"),
                error: nil,
                stale: false
            ))
        }
        
        // Forwarded operation and cached result may come in arbitrary order but both synchronously.
        XCTAssertEqual(trace[0..<4], [
            "requested: qur-id (query, cache-and-network)",
            "forwarded: qur-id (query, cache-and-network)",
            "resulted (false): qur-id hello (query)",
            "requested: qur-id (query, cache-and-network)",
        ])
        XCTAssertEqual(
            Set(trace[4..<6]),
            Set([
                "resulted (true): qur-id hello (query)",
                "forwarded: qur-id (query, cache-and-network)"
            ])
        )
        XCTAssertEqual(trace[6], "resulted (false): qur-id world (query)")
    }
    
    func testCacheOnlyDoesntForwardRequest() throws {
        let trace = environment { operations, results in
            let op = CacheExchangeTests.queryOperation.with(policy: .cacheOnly)
            
            operations.send(op)
            
            // randomly, unexplicably receive the result
            results.send(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("hello"),
                error: nil,
                stale: false
            ))
            
            operations.send(op)
        }
        
        // Forwarded operation and cached result may come in arbitrary order but both synchronously.
        XCTAssertEqual(trace, [
            "requested: qur-id (query, cache-only)",
            "resulted (false): qur-id hello (query)", // manually triggered
            "requested: qur-id (query, cache-only)",
            "resulted (false): qur-id hello (query)", // cache-only is never stale
        ])
    }
    
    func testNetworkOnlyForwardRequest() throws {
        let trace = environment { operations, results in
            let op = CacheExchangeTests.queryOperation.with(policy: .networkOnly)
            
            operations.send(op)
            
            // randomly, unexplicably receive the result
            results.send(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("hello"),
                error: nil,
                stale: false
            ))
            
            operations.send(op)
        }
        
        // Forwarded operation and cached result may come in arbitrary order but both synchronously.
        XCTAssertEqual(trace, [
            "requested: qur-id (query, network-only)",
            "forwarded: qur-id (query, network-only)",
            "resulted (false): qur-id hello (query)",
            "requested: qur-id (query, network-only)",
            "forwarded: qur-id (query, network-only)",
        ])
    }
    
    // MARK: - On Mutation
    
    func testOnMutationDoesNotCache() throws {
        let trace = environment { operations, results in
            operations.send(CacheExchangeTests.mutationOperation)
            operations.send(CacheExchangeTests.mutationOperation)
        }
        
        XCTAssertEqual(trace, [
            "requested: mut-id (mutation, cache-and-network)",
            "forwarded: mut-id (mutation, cache-and-network)",
            "requested: mut-id (mutation, cache-and-network)",
            "forwarded: mut-id (mutation, cache-and-network)",
        ])
    }
    
    func testMutationInvalidatesQueries() throws {
        let trace = environment { operations, results in
            let op = CacheExchangeTests.queryOperation.with(policy: .cacheAndNetwork)
            
            operations.send(op)
            
            results.send(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("hello"),
                error: nil,
                stale: false
            ))
            
            // somehow receive mutation result
            results.send(SwiftGraphQLClient.OperationResult(
                operation: CacheExchangeTests.mutationOperation,
                data: AnyCodable("much data"),
                error: nil,
                stale: false
            ))
        }
        
        // Forwarded operation and cached result may come in arbitrary order but both synchronously.
        XCTAssertEqual(trace, [
            "requested: qur-id (query, cache-and-network)",
            "forwarded: qur-id (query, cache-and-network)",
            "resulted (false): qur-id hello (query)",
            "reexecuted: qur-id (query, network-only)",
            "resulted (false): mut-id much data (mutation)",
            // reexecute of mock client doesn't re-enter operation into the pipeline
        ])
    }
    
    // MARK: - On Subscription
    
    func testOnSubscriptionForwardsSubscription() throws {
        let trace = environment { operations, results in
            operations.send(CacheExchangeTests.subscriptionOperation)
            operations.send(CacheExchangeTests.subscriptionOperation)
        }
        
        XCTAssertEqual(trace, [
            "requested: sub-id (subscription, cache-and-network)",
            "forwarded: sub-id (subscription, cache-and-network)",
            "requested: sub-id (subscription, cache-and-network)",
            "forwarded: sub-id (subscription, cache-and-network)",
        ])
    }
}
