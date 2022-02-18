import AuthenticationServices
import Foundation
import Valet

/// The secure valet where we store information about the current user.
private let valet = Valet.valet(
    with: Identifier(nonEmpty: "com.swiftgraphql.marvel")!,
    accessibility: .whenUnlocked
)

private enum Keys: String {
    case user
}

private struct Token: Codable {
    let authToken: String
}


/// A central point for handling authentication.
enum AuthClient {
    static var token: String? {
        AuthClient.cache.token
    }
    
    static var isAuthenticated: Published<Bool>.Publisher {
        AuthClient.cache.$isAuthenticated
    }
    
    // MARK: - Cache
    
    fileprivate static let cache = Cache()
    
    fileprivate class Cache: ObservableObject {
        
        /// Only `NetworkClient` should access this
        @Published var token: String?
        @Published var isAuthenticated: Bool = false
        
        init() {
            self.$token
                .map { $0 != nil }
                .removeDuplicates()
                .assign(to: &self.$isAuthenticated)
        }
        
        /// Persists the user to the keychain.
        @discardableResult
        private func persist(token: Token) -> Bool {
            do {
                let data = try JSONEncoder().encode(token)
                try valet.setObject(data, forKey: Keys.user.rawValue)
                return true
            } catch {
                return false
            }
        }
        
        /// Retrieves the token from the keychain.
        private func load() -> Token? {
            do {
                let data = try valet.object(forKey: Keys.user.rawValue)
                
                let decoder = JSONDecoder()
                guard let token = try? decoder.decode(Token.self, from: data) else {
                    return nil
                }
                
                return token
            } catch {
                return nil
            }
        }
        
        // MARK: - Methods
        
        /// Authenticates the user and starts relevant services.
        func login(token: Token) {
            self.token = token.authToken
            persist(token: token)
        }
        
        func loginFromKeychain() {
            let token = load()
            if let token = token?.authToken {
                self.token = token
            }
        }
        
        func logout() {
            try? valet.removeObject(forKey: Keys.user.rawValue)
            token = nil
        }
    }
    
    // MARK: - Methods
    
    /// Prompts user for login through Web OAuth provider.
    static func signInWithOAuth(onError: @escaping () -> Void) {
    }
    
    /// Tries to login user from cache.
    static func loginFromKeychain() {
        cache.loginFromKeychain()
    }
    
    /// Removes user cache and stops current session.
    static func logout() {
        cache.logout()
    }
}
