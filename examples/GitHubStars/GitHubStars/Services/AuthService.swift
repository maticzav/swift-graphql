import AuthenticationServices
import Combine
import Foundation
import Valet


/// A central store for handling authentication.
enum AuthClient {
    
    /// The value of the token used for authentication.
    static func getToken() -> String? {
        AuthClient.cache.token
    }
    
    /// A publisher that tells whether the user is authenticated or not.
    static var state: AnyPublisher<AuthState, Never> {
        AuthClient.cache.$state.eraseToAnyPublisher()
    }
    
    enum AuthState: Equatable {
        case loading
        case authenticated(User)
        case nosession
        case error(String)
    }
    
    // MARK: - Cache
    
    fileprivate static let cache = Cache()
    
    fileprivate class Cache: ObservableObject {
        
        /// The secure valet where we store information about the current user.
        private let valet = Valet.valet(
            with: Identifier(nonEmpty: "com.swiftgraphql.githubstars")!,
            accessibility: .whenUnlocked
        )
        
        private let encoder = JSONEncoder()
        private let decoder = JSONDecoder()
        
        var token: String? {
            didSet {
                guard let _ = token else {
                    return
                }
            
                NetworkClient.shared.query(User.viewer, policy: .cacheAndNetwork)
                    .receive(on: DispatchQueue.main)
                    .map { res -> User? in res.data }
                    .catch({ _ -> AnyPublisher<User?, Never> in
                        self.logout()
                        return Just(User?.none).eraseToAnyPublisher()
                    })
                    .removeDuplicates()
                    .assign(to: &self.$user)
            }
        }
        
        @Published var user: User?
        @Published var state: AuthState
        
        /// Reference to the login task.
        private var login: AnyCancellable?
        
        init() {
            self.token = nil
            self.user = nil
            self.state = .loading
            
            // Update the state as the user changes.
            self.$user
                .map { user in
                    if let user = user {
                        return .authenticated(user)
                    }
                    return .nosession
                }
                .removeDuplicates()
                .assign(to: &self.$state)
        }
        
        /// The structure that the client saves in the Valet.
        private struct Store: Codable {
            static var key: String = "user"
            
            let token: String
        }

        /// Persists the user in the keychain.
        @discardableResult
        private func persist(token: String) -> Bool {
            do {
                let store = Store(token: token)
                let data = try encoder.encode(store)
                try valet.setObject(data, forKey: Store.key)
                
                return true
            } catch {
                return false
            }
        }
        
        // MARK: - Methods
        
        /// Retrieves the token from the keychain.
        func load() {
            self.state = .loading
            guard let data = try? valet.object(forKey: Store.key),
                  let store = try? self.decoder.decode(Store.self, from: data) else {
                self.state = .nosession
                return
            }
            self.token = store.token
        }
        
        /// Authenticates the user and starts relevant services.
        func login(token: String) {
            self.token = token
            self.persist(token: token)
        }
        
        /// Removes the user session and logs it out.
        func logout() {
            NetworkClient.cache.clear()
            
            try? valet.removeObject(forKey: Store.key)
            self.token = nil
            self.user = nil
            self.state = .nosession
        }
    }
    
    // MARK: - Methods
    
    /// Authenticates user with the provided personal access token.
    static func login(token: String) {
        cache.login(token: token)
    }
    
    /// Tries to login user from cache.
    static func loginFromKeychain() {
        cache.load()
    }
    
    /// Removes user cache and stops current session.
    static func logout() {
        cache.logout()
    }
}
