import Foundation
import RxSwiftCombine

class TheSocialNetworkAppViewModel: ObservableObject {
    
    /// Authentication state of the current user.
    @Published var state: AuthClient.AuthState = .loading
    
    init() {
        AuthClient.state.assign(to: &self.$state)
    }
}
