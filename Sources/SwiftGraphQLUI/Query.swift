import Combine
import GraphQL
import SwiftGraphQL
import SwiftGraphQLClient
import SwiftUI

/// Lets you perform a query using a SwiftUI binding.
@propertyWrapper struct Query<T: Decodable>: DynamicProperty {
    
    /// Client from the context used to perform operations.
    @EnvironmentObject private var client: Client
    
    /// Holds the current value of the 
    @State private var result = Result<T>()
    
    /// Stream of values coming in
    private var cancellable: AnyCancellable?
    
    init<TypeLock>(
        query selection: Selection<T, TypeLock>,
        policy: SwiftGraphQLClient.Operation.Policy = .cacheFirst
    ) where TypeLock: GraphQLHttpOperation & Decodable {
        let request = URLRequest(url: URL(string: "")!)
        
        self.cancellable = self.client.query(for: selection, url: request, policy: policy)
            .sink(receiveValue: { [self] result in
                self.result = Result(
                    data: result.data,
                    errors: result.errors,
                    fetching: false,
                    stale: result.stale == true
                )
            })
    }
    
    // MARK: - Exposed Values
    
    var wrappedValue: (data: T?, errors: [CombinedError]?, fetching: Bool, stale: Bool) {
        get {
            return (data: result.data, errors: result.errors, fetching: result.fetching, stale: result.stale)
        }
        set {}
    }
    
    var projectedValue: Bool {
        false
    }
}
