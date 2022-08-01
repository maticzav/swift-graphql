import Combine
@testable import SwiftGraphQLClient
import XCTest

final class PublishersExtensionsTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    func testOnEndTriggeredWhenPublisherEnds() throws {
        var i = 0
        var received = [Int]()
        
        let subject = PassthroughSubject<Int, Never>()
        let _ = subject
            .eraseToAnyPublisher()
            .onEnd {
                i += 1
            }
            .sink { val in
                received.append(val)
            }
            .store(in: &self.cancellables)
        
        subject.send(42)
        
        XCTAssertEqual(i, 0)
        
        subject.send(completion: .finished)
        
        XCTAssertEqual(i, 1)
        XCTAssertEqual(received, [42])
    }
    
    func testOnEndTriggeredWhenSubscriberUnsubscribes() throws {
        var i = 0
        var received = [Int]()
        
        let subject = PassthroughSubject<Int, Never>()
        let cancellable = subject
            .eraseToAnyPublisher()
            .onEnd {
                i += 1
            }
            .sink { val in
                received.append(val)
            }
        
        subject.send(42)
        
        XCTAssertEqual(i, 0)
        
        cancellable.cancel()
        
        XCTAssertEqual(i, 1)
        XCTAssertEqual(received, [42])
    }
    
    // MARK: - TakeUntil tests
    
    func testTakeUntilEmitsValuesUntilTermination() throws {
        let expectation = expectation(description: "terminated")
        var received = [Int]()
        
        let terminator = PassthroughSubject<(), Never>()
        let publisher = PassthroughSubject<Int, Never>()
        
        publisher
            .takeUntil(terminator.eraseToAnyPublisher())
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { value in
                received.append(value)
            })
            .store(in: &self.cancellables)
        
        publisher.send(1)
        publisher.send(2)
        terminator.send(())
        publisher.send(3)
        
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(received, [1, 2])
    }
    
    func testCancelsUpstreamAfterTermination() throws {
        // NOTE: Expectation only fulfills if the upstream has been
        //       cancelled after termination.
        let expectation = expectation(description: "terminated")
        var received = [Int]()
        
        let terminator = PassthroughSubject<(), Never>()
        let publisher = PassthroughSubject<Int, Never>()
        
        publisher
            .handleEvents(receiveCancel: {
                expectation.fulfill()
            })
            .takeUntil(terminator.eraseToAnyPublisher())
            .sink(receiveValue: { value in
                received.append(value)
            })
            .store(in: &self.cancellables)
        
        publisher.send(1)
        terminator.send(())
        publisher.send(2)
        
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(received, [1])
    }
    
    func testForwardsFinishedEventToTheSubscriber() throws {
        // NOTE: This expectation only fulfills if subscriber
        //       receive completion event.
        let expectation = expectation(description: "finished")
        var received: [Int] = []
        
        let terminator = PassthroughSubject<(), Never>()
        let publisher = PassthroughSubject<Int, Never>()
        
        publisher
            .takeUntil(terminator.eraseToAnyPublisher())
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { value in
                received.append(value)
            })
            .store(in: &self.cancellables)
        
        publisher.send(1)
        publisher.send(completion: .finished)
        
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(received, [1])
    }
}
