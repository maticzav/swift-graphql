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
}
