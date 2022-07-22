@testable import SwiftGraphQL
import XCTest

/// Tests the serialization of the query from the AST.
final class HTTPTests: XCTestCase {
    
    /// Tests basic HTTP query performed against a server.
    func testHTTPQuery() throws {
        let expectation = expectation(description: "received response")
        
        let query = Selection.Query<String> {
            try $0.hello()
        }
        
        let endpoint = URL(string: "http://127.0.0.1:4000/graphql")!
        let request = URLRequest(url: endpoint)
        
        URLSession.shared.dataTask(with: request.querying(query)) { data, response, error in
            guard let result = try? data?.decode(query) else {
                XCTFail()
                return expectation.fulfill()
            }
            
            XCTAssertEqual(result.data, "Hello world!")
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 10)
    }
}
