import Combine
import GraphQL
@testable import SwiftGraphQLClient
import XCTest

final class FallbackExchangeTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    func testFiltersResults() throws {
        let expectation = expectation(description: "deallocated")
        
        let subject = PassthroughSubject<SwiftGraphQLClient.Operation, Never>()
        let operations = subject.share().eraseToAnyPublisher()
        
        let client = MockClient()
        
        let exchange = FallbackExchange(debug: true)
        exchange
            .register(client: client, operations: operations) { _ in
                Empty<OperationResult, Never>().eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in
                // Check that everything is filtered.
                XCTFail()
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
        subject.send(operation)
        subject.send(completion: .finished)
        
        waitForExpectations(timeout: 1)
    }
}
