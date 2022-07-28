import Foundation

class AuthViewModel: ObservableObject {
    @Published var username: String
    @Published var password: String
    
    @Published var error: String?
    
    init() {
        self.username = ""
        self.password = ""
        
        AuthClient.state
            .map { state in
                switch state {
                case .error(let message):
                    return message
                default:
                    return nil
                }
            }
            .assign(to: &self.$error)
    }
    
    var invalid: Bool {
        username.count <= 3 || password.count <= 3
    }
    
    func submit() {
        guard !self.invalid else {
            return
        }
        
        AuthClient.loginOrSignup(
            username: self.username,
            password: self.password
        )
    }
}
