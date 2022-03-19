import Combine
import SwiftGraphQL
import SwiftGraphQLClient
import SwiftUI

/// Lets you create a subscription using a SwiftUI binding.
@propertyWrapper struct Subscribe<
    Client: GraphQLClient & ObservableObject,
    T: Decodable
>: DynamicProperty {
    
    /// Client from the context used to perform operations.
    @EnvironmentObject private var client: Client
    
    /// Holds the current value of the
    @State private var result = Result<T>()
    
    /// Stream of values coming in
    private var cancellable: AnyCancellable?
    
    init<TypeLock>(
        query selection: Selection<T, TypeLock>,
        policy: SwiftGraphQLClient.Operation.Policy = .cacheFirst
    ) where TypeLock: GraphQLWebSocketOperation & Decodable {
        let request = URLRequest(url: URL(string: "")!)
        
        self.cancellable = self.client.subscribe(to: selection, url: request, policy: policy)
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
