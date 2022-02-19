import SwiftUI

struct SceneView: View {
    
    @State private var tab: Tab = .characters
    
    enum Tab: String, CaseIterable {
        case characters = "characters"
        case comics = "comics"
        case search = "search"
        case forum = "forum"
        
        var label: Label<Text, Image> {
            switch self {
            case .characters:
                return Label("Home", systemImage: "person.2")
            case .comics:
                return Label("Comics", systemImage: "newspaper")
            case .search:
                return Label("Search", systemImage: "magnifyingglass")
            case .forum:
                return Label("Forum", systemImage: "message")
            }
        }
        
        @ViewBuilder
        var view: some View {
            switch self {
            case .characters:
                CharactersTab()
            case .comics:
                ComicsTab()
            case .forum:
                ForumTab()
            case .search:
                SearchTab()
            }
        }
    }
    
    /// Tells which pages have tab-bar hidden.
    @State private var tabBarHidden = [Tab: Bool]()
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                self.tab.view
                    .onPreferenceChange(TabBarHiddenKey.self) { newValue in
                        tabBarHidden[self.tab] = newValue
                    }
                
                VStack {
                    Spacer()
                    
                    if (tabBarHidden[self.tab] != true) {
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("MarvelLogo")
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                }
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

struct TabBarHiddenKey: PreferenceKey {
    static let defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    /// Sets the preference for tab bar visibility of the current view.
    func tabBarHidden(_ isHidden: Bool = true) -> some View {
        preference(key: TabBarHiddenKey.self, value: isHidden)
    }
}

// MARK: - Previews

#if DEBUG
struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneView()
    }
}
#endif
