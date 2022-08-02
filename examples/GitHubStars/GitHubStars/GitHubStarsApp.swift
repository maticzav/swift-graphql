import SwiftUI

@main
struct GitHubStarsApp: App {
    @StateObject var vm: GitHubStarsViewModel = GitHubStarsViewModel()
    
    var body: some Scene {
        WindowGroup {
            self.content
                .onAppear { AuthClient.loginFromKeychain() }
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch vm.state {
        case .loading:
            self.loading
            
        case .nosession, .error:
            AuthView()
            
        case .authenticated(let user):
            FeedView(user: user)
        }
    }
    
    @ViewBuilder
    var loading: some View {
        VStack {
            ProgressView()
        }
    }
}
