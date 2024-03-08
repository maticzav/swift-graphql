import RxSwiftCombine
import GraphQL
@testable import GraphQLWebSocket
import XCTest



@available(macOS 12, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class ClientTests: XCTestCase {
    
    private var cancellables = Set<DisposeBag>()
    
    /// Returns the execution arguments for the counter subscription.
    private func count(from: Int, to: Int) -> ExecutionArgs {
        let args = ExecutionArgs(
            query: """
            subscription Counter {
                count(from: \(from), to: \(to))
            }
            """,
            variables: [:]
        )
        
        return args
    }
    
    /// Decodes a subscription result into an integer.
    private func decode(_ result: ExecutionResult) -> Int {
        (result.data.value as! [String: Int])["count"]!
    }
    
    // MARK: - Tests
    
    func testWebSocketConnectsAndEmitsEvents() throws {
        let xsexpect = expectation(description: "xs complete")
        let ysexpect = expectation(description: "ys complete")
        
        let request = URLRequest(url: URL(string: "ws://127.0.0.1:4000/graphql")!)
        let client = GraphQLWebSocket(request: request)
        
        client.onEvent()
            .compactMap({ msg -> Error? in
                switch msg {
                case .error(let err):
                    return err
                default:
                    return nil
                }
            })
            .subscribe(onNext:{ err in
                XCTFail()
            })
            .store(in: &self.cancellables)
        
        var xs = [Int]()
        var ys = [Int]()
        
        // We parallely check two GraphQL subscriptions.
        client.subscribe(self.count(from: 10, to: 5))
            .subscribe(onNext: { result in
                xs.append(self.decode(result))
            }, onCompleted: {
                xsexpect.fulfill()
            })
            .store(in: &self.cancellables)
        
        client.subscribe(self.count(from: 100, to: 105))
            .subscribe(onNext: { result in
                ys.append(self.decode(result))
            }, onCompleted: {
                ysexpect.fulfill()
            })
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual([10, 9, 8, 7, 6], xs)
        XCTAssertEqual([100, 101, 102, 103, 104], ys)
    }
    
}
