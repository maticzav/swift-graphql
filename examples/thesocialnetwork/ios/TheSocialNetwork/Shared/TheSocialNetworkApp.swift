import SwiftUI

@main
struct TheSocialNetworkApp: App {
    @ObservedObject var vm = TheSocialNetworkAppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ToastContainer {
                switch vm.state {
                case .loading:
                    self.loading
                case .nosession, .error:
                    self.auth
                case .authenticated(let user):
                    self.app(user: user)
                }
            }
            .onAppear {
                AuthClient.loginFromKeychain()
            }
        }
    }
    
    @ViewBuilder
    var auth: some View {
        AuthView()
    }
    
    @ViewBuilder
    func app(user: User) -> some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "square.grid.2x2")
                }
            AccountView(user: user)
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
        }
    }
    
    @ViewBuilder
    var loading: some View {
        VStack {
            ProgressView()
        }
    }
}
