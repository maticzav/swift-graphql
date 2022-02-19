import MarvelCore
import SwiftUI

/// Lets you browse comics in Marvel's universe.
struct ComicsTab: View {
    
    var comics: [Comic] = [
        .avangers,
        .captainamerica,
        .deadpool,
        .starwars,
        .silversurfer
    ]
    
    // MARK: - Views
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                ForEach(comics) { comic in
                    NavigationLink {
                        ComicView(comic: comic)
                            .navigationTitle(comic.title)
                    } label: {
                        ComicCell(comic: comic)
                    }
                }
            }
            .padding(.bottom, 120)
        }
        .padding()
        .background(Material.thin)
        .navigationTitle("Comics")
    }
    
    private var columns: [GridItem] {
        [GridItem(.flexible(maximum: 400)), GridItem(.flexible(maximum: 400))]
    }
}

struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        ComicsTab()
    }
}
