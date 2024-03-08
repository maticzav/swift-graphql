import RxSwiftCombine
import GraphQL
@testable import SwiftGraphQLClient
import XCTest

final class FallbackExchangeTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    func testFiltersResults() throws {
        let expectation = expectation(description: "deallocated")
        
        let subject = PublishSubject<SwiftGraphQLClient.Operation>()
        let operations = subject.share()
        
        let client = MockClient()
        
        let exchange = FallbackExchange(debug: true)
        exchange
            .register(client: client, operations: operations) { _ in
                Observable<OperationResult>.empty()
            }
            .subscribe(onNext: { _ in
                // Check that everything is filtered.
                XCTFail()
            }, onCompleted: {
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
        subject.onCompleted()
        
        waitForExpectations(timeout: 1)
    }
}
