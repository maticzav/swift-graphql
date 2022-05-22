import Combine
import GraphQL
@testable import GraphQLWebSocket
import XCTest



@available(macOS 12, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class ClientTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    func testWebSocketConnectsAndEmitsEvents() throws {
        let expectation = expectation(description: "Subscription Closed")
        
        let request = URLRequest(url: URL(string: "ws://localhost:4000/graphql")!)
        let client = GraphQLWebSocket(request: request)
        
        let args = ExecutionArgs(
            query: """
            subscription Counter {
                count(from: 10, to: 5)
            }
            """,
            variables: [:]
        )
        
        
        var values = [Int]()
        
        client.onEvent()
            .compactMap({ msg -> Error? in
                switch msg {
                case .error(let err):
                    return err
                default:
                    return nil
                }
            })
            .sink { err in
                print("ERR", err)
                XCTFail()
            }
            .store(in: &self.cancellables)
        
        client.subscribe(args)
            .sink { completion in
                expectation.fulfill()
            } receiveValue: { result in
                let n = (result.data.value as! [String: Int])["count"]!
                values.append(n)
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 15)
        
        XCTAssertEqual([10, 9, 8, 7, 6], values)

    }
}
