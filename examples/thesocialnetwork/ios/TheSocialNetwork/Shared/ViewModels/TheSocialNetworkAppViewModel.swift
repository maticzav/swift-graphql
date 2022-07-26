import Foundation
import Combine

class TheSocialNetworkAppViewModel: ObservableObject {
    @Published var state: AuthClient.AuthState = .loading
    
    init() {
        AuthClient.state.assign(to: &self.$state)
    }
}
