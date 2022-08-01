import Combine
@testable import SwiftGraphQLClient
import XCTest

final class PublishersExtensionsTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()

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
    
    func testTakeUntilCancelsUpstreamAfterTermination() throws {
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
    
    func testTakeUntilForwardsFinishedEventToTheSubscriber() throws {
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
    
    func testTakeUntilForwardsCancelEventToPublisher() throws {
        // NOTE: This expectation only fulfills if subscriber
        //       receive completion event.
        let expectation = expectation(description: "cancelled")
        var received: [Int] = []
        
        let terminator = PassthroughSubject<(), Never>()
        let publisher = PassthroughSubject<Int, Never>()
        
        var cancellable: AnyCancellable? = publisher
            .handleEvents(receiveCancel: {
                expectation.fulfill()
            })
            .takeUntil(terminator.eraseToAnyPublisher())
            .sink(receiveCompletion: { completion in
                XCTFail()
            }, receiveValue: { value in
                received.append(value)
            })
        
        publisher.send(1)
        cancellable?.cancel()
        cancellable = nil
        
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(received, [1])
    }
}
