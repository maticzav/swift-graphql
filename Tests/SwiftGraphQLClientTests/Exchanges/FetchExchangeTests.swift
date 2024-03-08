import RxSwiftCombine
import GraphQL
@testable import SwiftGraphQLClient
import XCTest

final class FetchExchangeTests: XCTestCase {
    struct MockURLSession: FetchSession {
        
        /// Mock handler used to create a mock data response of the request.
        var handler: (URLRequest) -> MockResponse
        
        enum MockResponse {
            case succcess(String)
            case error(Int)
        }
        
        func dataTaskPublisher(
            for request: URLRequest,
            with _: Data
        ) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
            switch self.handler(request) {
            case .succcess(let body):
                let data = Data(body.utf8)
                let response = URLResponse(
                    url: request.url ?? URL(string: "https://swift.org")!,
                    mimeType: nil,
                    expectedContentLength: 42,
                    textEncodingName: nil
                )
                
                return Just((data: data, response: response))
                
            case .error(let code):
                let error = URLError(rawValue: code)
                    return Observable<(data: Data, response: URLResponse)>.error(error)
            }
        }
        
    }
    
    /// Mock operation that we use in the tests.
    private static let queryOperation = SwiftGraphQLClient.Operation(
        id: "qur-id",
        kind: .query,
        request: URLRequest(url: URL(string: "https://www.mock.com")!),
        policy: .cacheAndNetwork,
        types: ["A", "B", "C"],
        args: ExecutionArgs(query: "", variables: [:])
    )
    
    /// Mock operation that we use in the tests.
    private static let mutationOperation = SwiftGraphQLClient.Operation(
        id: "mut-id",
        kind: .mutation,
        request: URLRequest(url: URL(string: "https://www.mock.com")!),
        policy: .cacheAndNetwork,
        types: ["A", "B"],
        args: ExecutionArgs(query: "", variables: [:])
    )
    
    private var cancelables = Set<AnyCancellable>()
    
    // MARK: - On Success
    
    func testReturnsResponseData() throws {
        let expectation = expectation(description: "Received Result")
        
        let operations = PassthroughSubject<SwiftGraphQLClient.Operation, Never>()
        
        let client = MockClient()
        let session = MockURLSession { _ in .succcess("{ \"data\": \"hello\" }") }
        
        let exchange = FetchExchange(session: session)
        exchange.register(
            client: client,
            operations: operations
        ) { ops in
            let downstream = ops
                .do(onNext: { _ in XCTFail() })
                .compactMap { _ in OperationResult?.none }
            
            return downstream
        }
        .subscribe(onNext: { result in
            XCTAssertEqual(result, OperationResult(
                operation: result.operation,
                data: AnyCodable("hello"),
                error: nil,
                stale: false)
            )
            
            expectation.fulfill()
        })
        .store(in: &self.cancelables)

        operations.onNext(FetchExchangeTests.queryOperation)
        waitForExpectations(timeout: 5)
    }
    
    // MARK: - On Error
    
    func testReturnsError() throws {
        let expectation = expectation(description: "Received Result")
        
        let operations = PassthroughSubject<SwiftGraphQLClient.Operation, Never>()
        
        let client = MockClient()
        let session = MockURLSession { request in
            .error(400)
        }
        
        let exchange = FetchExchange(session: session)
        exchange.register(
            client: client,
            operations: operations
        ) { ops in
            let downstream = ops
                .do(onNext: { _ in XCTFail() })
                .compactMap { _ in OperationResult?.none }
            
            return downstream
        }
        .subscribe(onNext: { result in
            XCTAssertEqual(
                result,
                OperationResult(
                    operation: result.operation,
                    data: nil,
                    error: .network(URLError(rawValue: 400)),
                    stale: false
                )
            )
            
            expectation.fulfill()
        })
        .store(in: &self.cancelables)

        operations.onNext(FetchExchangeTests.queryOperation)
        waitForExpectations(timeout: 5)
    }
    
    // MARK: - On Teardown
    
    func testTeardownDoesNotPerformFetch() throws {
        let expectation = expectation(description: "Received Result")
        
        let operations = PassthroughSubject<SwiftGraphQLClient.Operation, Never>()
        
        let client = MockClient()
        let session = MockURLSession { _ in
            XCTFail()
            
            return .error(400)
        }
        
        let exchange = FetchExchange(session: session)
        exchange.register(
            client: client,
            operations: operations
        ) { ops in
            let downstream = ops
                .do(onNext: { _ in
                    expectation.fulfill()
                })
                .compactMap { _ in OperationResult?.none }
            
            return downstream
        }
        .subscribe(onNext: { result in
            XCTFail()
        })
        .store(in: &self.cancelables)

        operations.onNext(FetchExchangeTests.queryOperation.with(kind: .teardown))
        
        waitForExpectations(timeout: 5)
    }
}

extension URLError {
    fileprivate init(rawValue: Int) {
        self.init(URLError.Code(rawValue: rawValue))
    }
}
