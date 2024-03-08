import RxSwift
import GraphQL
@testable import SwiftGraphQLClient
import XCTest

final class ComposeExchangeTests: XCTestCase {
    
    private struct DebugExchange: Exchange {
        
        /// Idenitifer of the debug exchange.
        var name: String
        
        /// Function used to communicate to the outside world what's happening inside the exchange.
        var trace: (String) -> Void
        
        func register(
            client: GraphQLClient,
            operations: Observable<SwiftGraphQLClient.Operation>,
            next: @escaping ExchangeIO
        ) -> Observable<OperationResult> {
            let downstream = operations
                .do(onNext: { _ in
                    self.trace("going down: \(name)")
                })
            
            let upstream = next(downstream)
                .do(onNext: { _ in
                    self.trace("going up: \(name)")
                })
            
            return upstream
        }
    }
    
    private var cancellables = Set<DisposeBag>()
    
    func testComposesExchangesCorrectly() throws {
        let expectation = expectation(description: "Received Logs")
        
        let subject = PublishSubject<SwiftGraphQLClient.Operation>()
        let operations = subject.share()
        
        let client = MockClient()
        
        var trace: [String] = []
        
        let exchange = ComposeExchange(exchanges: [
            DebugExchange(name: "A", trace: { trace.append($0) }),
            DebugExchange(name: "B", trace: { trace.append($0) }),
            DebugExchange(name: "C", trace: { trace.append($0) }),
        ])
        exchange
            .register(client: client, operations: operations) { ops in
                ops
                    .map { operation in
                        SwiftGraphQLClient.OperationResult(
                            operation: operation,
                            data: nil,
                            error: nil,
                            stale: false
                        )
                    }
            }
            .subscribe(onNext: { result in
                expectation.fulfill()
            })
            .store(in: &self.cancellables)
        
        let operation = SwiftGraphQLClient.Operation(
            id: "mck-id",
            kind: .query,
            request: URLRequest(url: URL(string: "https://mock.com")!),
            policy: .cacheAndNetwork,
            types: [],
            args: ExecutionArgs(query: "", variables: [:])
        )
        subject.onNext(operation)
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(trace, [
            "going down: A",
            "going down: B",
            "going down: C",
            "going up: C",
            "going up: B",
            "going up: A",
        ])
    }
    
}
