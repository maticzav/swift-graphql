import Foundation

import Combine
import Foundation
import GraphQL

/// Exchange that prevents multiple executions of the same operation.
public class DedupExchange: Exchange {
    
    /// Operation IDs that are currently awaiting responses.
    private var inFlightKeys: Set<String>
    
    init() {
        inFlightKeys = Set()
    }
    
    // MARK: - Methods
    
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        let downstream = operations
            .filter { operation in
                if operation.kind == .teardown {
                    self.inFlightKeys.remove(operation.id)
                    return true
                }
                
                if operation.kind == .mutation {
                    return true
                }
                
                let isInFlight = self.inFlightKeys.contains(operation.id)
                self.inFlightKeys.insert(operation.id)
                
                return !isInFlight
            }
            .eraseToAnyPublisher()
        
        let upstream = next(downstream)
            .onPush { result in
                self.inFlightKeys.remove(result.operation.id)
            }
            .eraseToAnyPublisher()
        
        return upstream
    }
}

