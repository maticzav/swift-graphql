import Combine
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
            operations: AnyPublisher<SwiftGraphQLClient.Operation, Never>,
            next: @escaping ExchangeIO
        ) -> AnyPublisher<OperationResult, Never> {
            let downstream = operations
                .handleEvents(receiveOutput: { _ in
                    self.trace("going down: \(name)")
                })
                .eraseToAnyPublisher()
            
            let upstream = next(downstream)
                .handleEvents(receiveOutput: { _ in
                    self.trace("going up: \(name)")
                })
                .eraseToAnyPublisher()
            
            return upstream
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func testComposesExchangesCorrectly() throws {
        let expectation = expectation(description: "Received Logs")
        
        let subject = PassthroughSubject<SwiftGraphQLClient.Operation, Never>()
        let operations = subject.share().eraseToAnyPublisher()
        
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
                            errors: [],
                            stale: false
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .sink { result in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        let operation = SwiftGraphQLClient.Operation(
            id: "mck-id",
            kind: .query,
            request: URLRequest(url: URL(string: "https://mock.com")!),
            policy: .cacheAndNetwork,
            types: [],
            args: ExecutionArgs(query: "", variables: [:])
        )
        subject.send(operation)
        
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
