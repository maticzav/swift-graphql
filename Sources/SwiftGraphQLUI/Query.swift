import Combine
import GraphQL
import SwiftGraphQL
import SwiftGraphQLClient
import SwiftUI

struct Example: View {
    
    static let helloworld = Selection.Query<String> {
        try $0.hello()
    }
    
    private func search(query: String) -> Selection.Query<[String]> {
        Selection.Query<[String]> {
            try $0.search(
                query: InputObjects.Search(query: query),
                selection: Selection.SearchResult<String> {
                    try $0.on(
                        character: Selection.Character<String> { try $0.name() },
                        comic: Selection.Comic<String> { try $0.title() }
                    )
                }.list
            )
        }
    }
    
    @Query<[String]>(policy: .cacheFirst) var results
    @State var query: String = ""
    
    var body: some View {
        Text("hey")
            .onAppear {
                results.fetch(search(query: query))
            }
    }
    
}

/// Lets you perform a query using a SwiftUI binding.
///
/// - NOTE: `T` tells the type of values this query expects to return.
@propertyWrapper public struct Query<T>: DynamicProperty {
    @SwiftGraphQLEnvironment var env
    
    /// Object that triggers rerendering of the component when receiving a new value from the client.
    @StateObject private var loader: Loader = Loader()
    
    /// A value describing how the client should search for values.
    fileprivate let policy: SwiftGraphQLClient.Operation.Policy
    
    public init(policy: SwiftGraphQLClient.Operation.Policy = .cacheFirst) {
        self.policy = policy
    }
    
    public var wrappedValue: WrappedValue {
        WrappedValue(query: self)
    }
    
    /// Structure providing access to query status.
    public struct WrappedValue {
        
        /// Back reference to the query structure.
        fileprivate let query: Query<T>
        
        /// The fetched value of the query.
        public var result: Result {
            query.loader.result
        }
        
        /// Creates a stream of values.
        public func fetch<TypeLock>(_ selection: Selection<T, TypeLock>) where TypeLock: GraphQLHttpOperation {
            query.loader.fetch(
                client: self.query.env.client,
                selection: selection,
                policy: self.query.policy
            )
        }
        
        /// Manually reexecute the query.
        public func refetch() async {
            await query.loader.reexecute()
        }
    }
    
    /// Presents the loading state of the fetched value.
    public enum Result {
        case loading
        case failure([CombinedError])
        case success(T)
        case refreshing(T)
        
        /// Tells whether the result is loading.
        public var isLoading: Bool {
            if case .loading = self {
                return true
            }
            return false
        }
        
        /// Returns a list of errors if one happened during fetching.
        public var error: [CombinedError]? {
            guard case .failure(let error) = self else {
                return nil
            }
            
            return error
        }
        
        /// Returns the data if it's already available.
        public var data: T? {
            switch self {
            case .success(let data):
                return data
            case .refreshing(let data):
                return data
            default:
                return nil
            }
        }
        
        /// Tells whether we are anticipating new data to come.
        public var isStale: Bool {
            if case .refreshing = self {
                return true
            }
            return false
        }
    }
    
    private class Loader: ObservableObject {
        
        /// Current data received from the server.
        @Published var result: Result<T> = .loading
        
        /// Saved reference to the pipeline emitting new values.
        private var pipeline: AnyCancellable?
        
        /// A utility function that may be called to reexecute the query.
        private var execute: (() -> Void)?
        
        /// Creates a new subscription for the given query.
        func fetch<TypeLock>(
            client: GraphQLClient,
            selection: Selection<T, TypeLock>,
            policy: SwiftGraphQLClient.Operation.Policy
        ) where TypeLock: GraphQLHttpOperation {
            
            self.execute = { [self] in
                // We persist a strong reference with `self` because
                // loader drops everything on deinitialization.
                //
                // NOTE: rethink if this really doesn't result in a memory leak.
                switch self.result {
                case .success(let data):
                    self.result = .refreshing(data)
                case .failure:
                    self.result = .loading
                case .loading, .refreshing:
                    ()
                }
                
                self.pipeline = client
                    .query(for: selection, policy: policy)
                    .sink(receiveValue: { result in
                        guard result.errors.isEmpty else {
                            self.result = .failure(result.errors)
                            return
                        }
                        
                        
                    })
            }
            
            // We autoexecute the request when the user performs a fetch call.
            self.execute?()
        }
        
        /// Reexecutes the query function with same data.
        func reexecute() {
            guard let fn = self.execute else {
                return
            }
            fn()
        }
        
    }
}
