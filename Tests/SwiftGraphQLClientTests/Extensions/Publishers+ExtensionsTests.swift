import Combine
@testable import SwiftGraphQLClient
import XCTest

final class PublishersExtensionsTests: XCTestCase {
    
    func testOnStartTriggeredCorrectly() throws {
        var i = 0
        var received = [Int]()
        
        let publisher = [1, 2, 3]
            .publisher
            .eraseToAnyPublisher()
        
        let detached = publisher.onStart {
            i += 1
        }
        
        XCTAssertEqual(i, 0)
        
        let _ = detached.sink { i in
            received.append(i)
        }
        
        XCTAssertEqual(i, 1)
        XCTAssertEqual(received, [1, 2, 3])
    }
    
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
    
    func testOnPushTriggeredCorrectly() throws {
        var received = [Int]()
        
        let subject = PassthroughSubject<Int, Never>()
        let _ = subject
            .eraseToAnyPublisher()
            .onPush { val in
                received.append(val)
            }
            .sink { _ in }
            .store(in: &self.cancellables)
        
        subject.send(17)
        subject.send(3)
        subject.send(2000)
        
        XCTAssertEqual(received, [17, 3, 2000])
    }
    
    func testTakeUntil() throws {
        var received = [Int]()
        var completed = false
        
        let terminator = PassthroughSubject<Bool, Never>()
        let publisher = PassthroughSubject<Int, Never>()
        
        publisher
            .takeUntil(terminator.eraseToAnyPublisher())
            .sink(receiveCompletion: { completion in
                completed = completion == .finished
            }, receiveValue: { value in
                received.append(value)
            })
            .store(in: &self.cancellables)
        
        publisher.send(1)
        terminator.send(false)
        publisher.send(2)
        terminator.send(true)
        
        XCTAssertTrue(completed)
        
        publisher.send(3)
        
        XCTAssertEqual(received, [1, 2])
        XCTAssertTrue(completed)
    }
    
}
