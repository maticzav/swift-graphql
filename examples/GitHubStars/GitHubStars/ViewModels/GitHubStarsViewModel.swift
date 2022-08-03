import Foundation

class GitHubStarsViewModel: ObservableObject {
    
    @Published var state: AuthClient.AuthState
    
    
    init() {
        self.state = .loading
        
        AuthClient.state.assign(to: &self.$state)
    }
}
