import Combine
import GraphQL
@testable import GraphQLWebSocket
import XCTest

// NOTE: start local test server before running the tests

final class ClientTests: XCTestCase {
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
        
        var cancellables = Set<AnyCancellable>()
        
        client.onEvent()
            .compactMap { msg -> Error? in
                switch msg {
                case .error(let err):
                    return err
                default:
                    return nil
                }
            }
            .sink { _ in
                XCTFail()
            }
            .store(in: &cancellables)
        
        var xs = [Int]()
        var ys = [Int]()
        
        // We parallely check two GraphQL subscriptions.
        client.subscribe(self.count(from: 10, to: 5))
            .sink { _ in
                xsexpect.fulfill()
            } receiveValue: { result in
                xs.append(self.decode(result))
            }
            .store(in: &cancellables)
        
        client.subscribe(self.count(from: 100, to: 105))
            .sink { _ in
                ysexpect.fulfill()
            } receiveValue: { result in
                ys.append(self.decode(result))
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual([10, 9, 8, 7, 6], xs)
        XCTAssertEqual([100, 101, 102, 103, 104], ys)
    }
    
    func testWebSocketCloseAfterComplete() throws {
        let subComplete = expectation(description: "subscription complete")
        
        let request = URLRequest(url: URL(string: "ws://127.0.0.1:4000/graphql")!)
        let config = GraphQLWebSocketConfiguration()
        config.logger.logLevel = .debug
        config.behaviour = .eager
        let client = GraphQLWebSocket(request: request, config: config)
                
        XCTAssertEqual(client.health, .connecting)

        var cancellables = Set<AnyCancellable>()
        
        let conClosed = expectation(description: "connection closed")
        client.onEvent()
            .sink { event in
                switch event {
                case .closed:
                    conClosed.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // start a subscription which will be commpleted within 5 seconds
        client.subscribe(self.count(from: 10, to: 8))
            .sink { _ in
                XCTAssertEqual(client.health, .acknowledged)
                subComplete.fulfill()
            } receiveValue: { _ in
                XCTAssertEqual(client.health, .acknowledged)
            }
            .store(in: &cancellables)

        // wait for the subscriptions to complete
        wait(for: [subComplete], timeout: 5)
        
        XCTAssertEqual(client.health, .acknowledged)
        
        // wait for socket to be closed
        // note that the current implementation will not allow closing
        // if there are not complete subscriptions
        XCTAssertTrue(client.pipelines.isEmpty)
        client.close()
        
        wait(for: [conClosed], timeout: 5)
        
        XCTAssertEqual(client.health, .notconnected)
    }
    
    func testWebSocketReconnect() throws {
        let subComplete = expectation(description: "subscription complete")
        
        let request = URLRequest(url: URL(string: "ws://127.0.0.1:4000/graphql")!)
        let config = GraphQLWebSocketConfiguration()
        config.logger.logLevel = .debug
        config.behaviour = .eager
        let client = GraphQLWebSocket(request: request, config: config)
                
        XCTAssertEqual(client.health, .connecting)

        var cancellables = Set<AnyCancellable>()
        
        let conClosed = expectation(description: "connection closed")
        client.onEvent()
            .sink { event in
                switch event {
                case .closed:
                    conClosed.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // start a subscription which will be commpleted within 5 seconds
        client.subscribe(self.count(from: 10, to: 8))
            .sink { _ in
                XCTAssertEqual(client.health, .acknowledged)
                subComplete.fulfill()
            } receiveValue: { _ in
                XCTAssertEqual(client.health, .acknowledged)
            }
            .store(in: &cancellables)

        // wait for the subscriptions to complete
        wait(for: [subComplete], timeout: 5)

        XCTAssertEqual(client.health, .acknowledged)
        
        // wait for socket to be closed
        // note that the current implementation will not allow closing
        // if there are not complete subscriptions
        XCTAssertTrue(client.pipelines.isEmpty)
        client.close()
        
        wait(for: [conClosed], timeout: 5)
        
        XCTAssertEqual(client.health, .notconnected)
        
        // start new subscription which will try to reconnect, it should complate withing 5 seconds
        let sub2Complete = expectation(description: "subscription2 complete")
        client.subscribe(self.count(from: 10, to: 8))
            .sink { _ in
                XCTAssertEqual(client.health, .acknowledged)
                sub2Complete.fulfill()
            } receiveValue: { _ in
                XCTAssertEqual(client.health, .acknowledged)
            }
            .store(in: &cancellables)

        // wait for the subscriptions to complete
        wait(for: [sub2Complete], timeout: 5)
        
        XCTAssertEqual(client.health, .acknowledged)
        XCTAssertTrue(client.pipelines.isEmpty)
    }
}
