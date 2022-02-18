import SwiftUI

struct SceneView: View {
    
    @State private var tab: Tab = .home
    
    enum Tab: String, CaseIterable {
        case home = "home"
        case search = "search"
        case settings = "settings"
        
        var label: Label<Text, Image> {
            switch self {
            case .home:
                return Label("Home", systemImage: "house")
            case .search:
                return Label("Search", systemImage: "magnifyingglass")
            case .settings:
                return Label("Settings", systemImage: "gearshape")
            }
        }
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HomeTab()
                .opacity(self.tab == .home ? 1 : 0)
            
            SearchTab()
                .opacity(self.tab == .search ? 1 : 0)
            
            SettingsTab()
                .opacity(self.tab == .settings ? 1 : 0)
            
            
            VStack {
                Spacer()
                
                tabBar
                    .frame(height: 49)
                    .background {
                        ZStack(alignment: .top) {
                            Divider()
                                .foregroundColor(.gray)
                                .frame(height: 1)

                            VisualEffectView(effect: UIBlurEffect(style: .regular))
                        }
                        .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    
    @ViewBuilder
    var tabBar: some View {
        HStack {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button { self.tab = tab } label: {
                    tab.label
                        .font(Font.system(size: 16, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                }
                .foregroundColor(self.tab == tab ? Color.black : Color.black.opacity(0.3))
            }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneView()
    }
}
