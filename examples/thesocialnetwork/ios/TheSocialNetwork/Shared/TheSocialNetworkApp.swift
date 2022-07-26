import SwiftUI

@main
struct TheSocialNetworkApp: App {
    @ObservedObject var vm = TheSocialNetworkAppViewModel()
    
    var body: some Scene {
        WindowGroup {
            switch vm.state {
            case .loading:
                self.loading
            case .nosession:
                self.auth
            case .authenticated:
                self.app
            }
            
        }
    }
    
    @ViewBuilder
    var auth: some View {
        AuthView()
    }
    
    @ViewBuilder
    var app: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Received", systemImage: "tray.and.arrow.down.fill")
                }
            AccountView()
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
