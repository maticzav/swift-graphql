import Combine
import GraphQL
@testable import SwiftGraphQLClient
import XCTest

final class FallbackExchangeTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    func testFiltersResultsAndWarnsAboutInput() throws {
        let expectation = expectation(description: "Received Logs")
        
        let subject = PassthroughSubject<SwiftGraphQLClient.Operation, Never>()
        let operations = subject.share().eraseToAnyPublisher()
        
        var called = false
        
        let client = MockClient(customLog: { _ in
            called = true
            expectation.fulfill()
        })
        
        let exchange = FallbackExchange(debug: true)
        exchange
            .register(client: client, operations: operations) { _ in
                Empty<OperationResult, Never>().eraseToAnyPublisher()
            }
            .sink { result in
                // Check that everything is filtered.
                XCTFail()
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
        
        XCTAssertTrue(called)
    }
    
    func testFiltersResultsAndDoesntWarnAboutTeardown() throws {
        let subject = PassthroughSubject<SwiftGraphQLClient.Operation, Never>()
        let operations = subject.share().eraseToAnyPublisher()
        
        let client = MockClient(customLog: { _ in
            // Make sure function isn't called.
            XCTFail()
        })
        
        let exchange = FallbackExchange(debug: true)
        exchange
            .register(client: client, operations: operations) { _ in
                Empty<OperationResult, Never>().eraseToAnyPublisher()
            }
            .sink { result in
                // Check that everything is filtered.
                XCTFail()
            }
            .store(in: &self.cancellables)
        
        let operation = SwiftGraphQLClient.Operation(
            id: "mck-id",
            kind: .teardown,
            request: URLRequest(url: URL(string: "https://mock.com")!),
            policy: .cacheAndNetwork,
            types: [],
            args: ExecutionArgs(query: "", variables: [:])
        )
        subject.send(operation)
    }
    
    
}
