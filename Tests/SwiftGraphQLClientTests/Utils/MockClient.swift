import Combine
import Foundation
import SwiftGraphQLClient

/// A client that you can use to perform tests on exchanges.
class MockClient: GraphQLClient {
    var request: URLRequest
    
    private var customLog: ((String) -> Void)?
    
    private var customExecute: ((SwiftGraphQLClient.Operation) -> AnyPublisher<OperationResult, Never>)?
    
    private var customReexecute: ((SwiftGraphQLClient.Operation) -> Void)?
    
    // MARK: - Initializer
    
    init(
        customLog: ((String) -> Void)? = nil,
        customExecute: ((SwiftGraphQLClient.Operation) -> AnyPublisher<OperationResult, Never>)? = nil,
        customReexecute: ((SwiftGraphQLClient.Operation) -> Void)? = nil
    ) {
        self.request = URLRequest(url: URL(string: "https://demo.com")!)
        self.customLog = customLog
        self.customExecute = customExecute
        self.customReexecute = customReexecute
    }
    
    // MARK: - Methods
    
    func log(message: String) {
        if let customLog = customLog {
            customLog(message)
        }
    }
    
    func execute(operation: SwiftGraphQLClient.Operation) -> AnyPublisher<OperationResult, Never> {
        guard let customExecute = customExecute else {
            return Empty<OperationResult, Never>().eraseToAnyPublisher()
        }

        return customExecute(operation)
    }
    
    func reexecute(operation: SwiftGraphQLClient.Operation) {
        if let customReexecute = customReexecute {
            customReexecute(operation)
        }
    }
}


