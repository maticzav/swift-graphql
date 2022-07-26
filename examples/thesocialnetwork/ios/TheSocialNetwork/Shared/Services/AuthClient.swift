import AuthenticationServices
import Combine
import Foundation
import Valet


/// A central store for handling authentication.
enum AuthClient {
    
    /// The value of the token used for authentication.
    static var token: String? {
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
    }
    
    // MARK: - Cache
    
    fileprivate static let cache = Cache()
    
    fileprivate class Cache: ObservableObject {
        
        /// The secure valet where we store information about the current user.
        private let valet = Valet.valet(
            with: Identifier(nonEmpty: "com.swiftgraphql.thesocialnetwork")!,
            accessibility: .whenUnlocked
        )
        
        private let encoder = JSONEncoder()
        private let decoder = JSONDecoder()
        
        @Published var token: String? = nil
        @Published var user: User? = nil
        
        @Published var state: AuthState = .loading
        
        /// Reference to the login task.
        private var login: AnyCancellable?
        
        init() {
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
            
            // Fetch user whenever token changes.
            self.$token
                .filter { token in token != nil }
                .flatMap { _ in
                    return NetworkClient.shared.query(User.viewer, policy: .networkOnly)
                }
                .map { res in
                    if let data = res.data, let user = data {
                        return user
                    }
                    
                    // Logout the user if the token doesn't apply to a session.
                    self.logout()
                    return nil
                }
                .removeDuplicates()
                .assign(to: &self.$user)
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
            do {
                let data = try valet.object(forKey: Store.key)
                if let store = try? self.decoder.decode(Store.self, from: data) {
                    self.token = store.token
                }
            } catch {
                self.token = nil
                self.state = .nosession
            }
        }
        
        /// Authenticates the user and starts relevant services.
        func login(username: String, password: String) {
            self.state = .loading
            
            let auth = User.login(username: username, password: password)
            self.login = NetworkClient.shared.query(auth)
                .sink(receiveValue: { result in
                    
                    // Login the user if we found the token.
                    if let data = result.data, let token = data {
                        self.token = token
                        self.persist(token: token)
                        return
                    }
                    
                    // Logout if the session is invalid.
                    self.logout()
                })
        }
        
        func logout() {
            try? valet.removeObject(forKey: Store.key)
            self.token = nil
            self.state = .nosession
        }
    }
    
    // MARK: - Methods
    
    /// Authenticates user with username and password.
    static func loginOrSignup(username: String, password: String) {
        cache.login(username: username, password: password)
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
