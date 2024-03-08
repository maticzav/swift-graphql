import RxSwift
import Foundation
import Logging
import SwiftGraphQLClient

/// A client that you can use to perform tests on exchanges.
class MockClient: GraphQLClient {
    var request: URLRequest
    
    private var customExecute: ((SwiftGraphQLClient.Operation) -> Observable<OperationResult>)?
    
    private var customReexecute: ((SwiftGraphQLClient.Operation) -> Void)?
    
    // MARK: - Initializer
    
    init(
        customExecute: ((SwiftGraphQLClient.Operation) -> Observable<OperationResult>)? = nil,
        customReexecute: ((SwiftGraphQLClient.Operation) -> Void)? = nil
    ) {
        self.request = URLRequest(url: URL(string: "https://demo.com")!)
        self.customExecute = customExecute
        self.customReexecute = customReexecute
    }
    
    // MARK: - Methods
    
    var logger: Logger = Logger(label: "com.client.tests")
    
    func execute(operation: SwiftGraphQLClient.Operation) -> Observable<OperationResult> {
        guard let customExecute = customExecute else {
            return Observable<OperationResult>.empty()
        }

        return customExecute(operation)
    }
    
    func reexecute(operation: SwiftGraphQLClient.Operation) {
        if let customReexecute = customReexecute {
            customReexecute(operation)
        }
    }
}


