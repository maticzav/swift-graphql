import Foundation

import RxSwiftCombine
import Foundation
import GraphQL

/// Exchange that prevents multiple executions of the same operation from running in parallel.
///
/// It wouldn't make sense to send the same operation / request twice in parallel (i.e. executing the second one
/// while waiting for the result of the first one).
public class DedupExchange: Exchange {
    
    /// Operation IDs that are currently awaiting responses.
    private var inFlightKeys: Set<String>
    
    public init() {
        self.inFlightKeys = Set()
    }
    
    // MARK: - Methods
    
    public func register(
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
                
                // It's crucial that we figure out whether the opearation is in-flight
                // before modifying the store because otherwise every operation would
                // always be in-flight.
                let isInFlight = self.inFlightKeys.contains(operation.id)
                self.inFlightKeys.insert(operation.id)
                
                return !isInFlight
            }
            .eraseToAnyPublisher()
        
        let upstream = next(downstream)
            .do(onNext: { result in
                self.inFlightKeys.remove(result.operation.id)
            })
            .eraseToAnyPublisher()
        
        return upstream
    }
}

