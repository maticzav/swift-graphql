import Foundation

import Combine
import Foundation
import GraphQL

/// Exchange that lets you add authorization to your opertions.
public class AuthExchange: Exchange {
    
    /// The name of the header containing the authorization information.
    private var header: String
    
    /// Function that returns a token to use for authorization.
    private var getToken: () -> String?
    
    init(header: String, getToken: @escaping () -> String?) {
        self.header = header
        self.getToken = getToken
    }
    
    // MARK: - Methods
    
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        let downstream = operations
            .map { operation -> Operation in
                guard let token = self.getToken() else {
                    return operation
                }
                
                var copy = operation
                copy.request.setValue(token, forHTTPHeaderField: self.header)
                return copy
            }
            .eraseToAnyPublisher()
        
        return next(downstream)
    }
}

