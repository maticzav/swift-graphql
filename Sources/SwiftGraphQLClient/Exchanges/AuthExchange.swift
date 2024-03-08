import Foundation
import RxSwift
import Foundation
import GraphQL

/// Exchange that lets you add authorization header to your operations.
///
/// - NOTE: `getToken` function should return the whole header value including the token.
public class AuthExchange: Exchange {
    
    /// The name of the header containing the authorization information.
    private var header: String
    
    /// Function that returns a token to use for authorization.
    private var getToken: () -> String?
    
    public init(header: String, getToken: @escaping () -> String?) {
        self.header = header
        self.getToken = getToken
    }
    
    // MARK: - Methods
    
    public func register(
        client: GraphQLClient,
        operations: Observable<Operation>,
        next: ExchangeIO
    ) -> Observable<OperationResult> {
        let downstream = operations
            .map { operation -> Operation in
                guard let token = self.getToken() else {
                    return operation
                }
                
                var copy = operation
                copy.request.setValue(token, forHTTPHeaderField: self.header)
                return copy
            }
        
        return next(downstream)
    }
}

