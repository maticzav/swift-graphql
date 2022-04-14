import Combine
@testable import GraphQLWebSocket
import XCTest

final class PublisherExtensionsTests: XCTestCase {
    
    func testCountingPublisher() throws {
        let subject = PassthroughSubject<Int, Never>()
        
        var totals = [Int]()
        var remainings = [Int]()
        
        var values = [Int]()
        
        let publisher = subject
            .counter { total in
                totals.append(total)
            } onDisconnect: { remaining in
                remainings.append(remaining)
            }
            .eraseToAnyPublisher()

        let first = publisher.sink { val in
            values.append(val)
        }
        
        let second = publisher.sink { val in
            values.append(val)
        }
        
        subject.send(1)
        subject.send(2)
        
        XCTAssertEqual(values, [1, 1, 2, 2])
        
        first.cancel()
        second.cancel()
        
        XCTAssertEqual(totals, [1, 2])
        XCTAssertEqual(remainings, [1, 0])
    }
    
    func testShareOperatorWorksAsExpected() throws {
        let subject = PassthroughSubject<Int, Never>()
        
        var totals = [Int]()
        var remainings = [Int]()
        
        var values = [Int]()
        
        let publisher = subject
            .counter { total in
                totals.append(total)
            } onDisconnect: { remaining in
                remainings.append(remaining)
            }
            .share()
            .eraseToAnyPublisher()

        let first = publisher.sink { val in
            values.append(val)
        }
        
        let second = publisher.sink { val in
            values.append(val)
        }
        
        subject.send(1)
        subject.send(2)
        
        XCTAssertEqual(values, [1, 1, 2, 2])
        
        first.cancel()
        second.cancel()
        
        XCTAssertEqual(totals, [1])
        XCTAssertEqual(remainings, [0])
    }
}
