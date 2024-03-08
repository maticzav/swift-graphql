import RxSwiftCombine
import GraphQL
import Foundation
@testable import SwiftGraphQLClient
import XCTest

final class CacheExchangeTests: XCTestCase {
    
    private var cancellables = Set<DisposeBag>()
    
    /// Function that executes desired operations in prepared environment and returns the trace.
    func environment(
        _ fn: (PublishSubject<SwiftGraphQLClient.Operation>, PublishSubject<SwiftGraphQLClient.OperationResult>) -> Void
    ) -> [String] {
        var trace: [String] = []
        
        let operations = PublishSubject<SwiftGraphQLClient.Operation>()
        let results = PublishSubject<SwiftGraphQLClient.OperationResult>()
        
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
        ) { ops in
            let downstream = ops
                .do(onNext: { operation in
                    trace.append("forwarded: \(operation.id) (\(operation.kind.rawValue), \(operation.policy.rawValue))")
                })
                .compactMap({ op in
                    SwiftGraphQLClient.OperationResult?.none
                })
            
            let upstream = Observable.merge(downstream, results)
            
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
            operations.onNext(CacheExchangeTests.queryOperation.with(policy: .cacheFirst))
            operations.onNext(CacheExchangeTests.queryOperation.with(policy: .cacheFirst))
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
            
            operations.onNext(op)
            results.onNext(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("hello"),
                error: nil,
                stale: false
            ))
            operations.onNext(op)
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
            
            operations.onNext(op)
            results.onNext(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("hello"),
                error: nil,
                stale: false
            ))
            operations.onNext(op)
            results.onNext(SwiftGraphQLClient.OperationResult(
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
            
            operations.onNext(op)
            
            // randomly, unexplicably receive the result
            results.onNext(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("hello"),
                error: nil,
                stale: false
            ))
            
            operations.onNext(op)
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
            
            operations.onNext(op)
            
            // randomly, unexplicably receive the result
            results.onNext(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("hello"),
                error: nil,
                stale: false
            ))
            
            operations.onNext(op)
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
            operations.onNext(CacheExchangeTests.mutationOperation)
            operations.onNext(CacheExchangeTests.mutationOperation)
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
            
            operations.onNext(op)
            
            results.onNext(SwiftGraphQLClient.OperationResult(
                operation: op,
                data: AnyCodable("hello"),
                error: nil,
                stale: false
            ))
            
            // somehow receive mutation result
            results.onNext(SwiftGraphQLClient.OperationResult(
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
            operations.onNext(CacheExchangeTests.subscriptionOperation)
            operations.onNext(CacheExchangeTests.subscriptionOperation)
        }
        
        XCTAssertEqual(trace, [
            "requested: sub-id (subscription, cache-and-network)",
            "forwarded: sub-id (subscription, cache-and-network)",
            "requested: sub-id (subscription, cache-and-network)",
            "forwarded: sub-id (subscription, cache-and-network)",
        ])
    }
}
