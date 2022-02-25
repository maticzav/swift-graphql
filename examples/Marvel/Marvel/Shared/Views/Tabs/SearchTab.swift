import MarvelCore
import SwiftUI

/// Lets you search content from Marvel universe.
struct SearchTab: View {
    
    /// Tells whether user is currently interacting with the search bar.
    @State private var isSearching: Bool = false
    
    @State private var searchText: String = ""
    
    var body: some View {
        ScrollView(.vertical) {
            SearchResult(
                isSearching: self.$isSearching,
                searchText: self.$searchText
            )
        }
        .navigationTitle("Search")
        .searchable(text: self.$searchText, placement: .navigationBarDrawer(displayMode: .always))
        .tabBarHidden(isSearching)
    }
}

struct SearchResult: View {
    @Environment(\.isSearching) var isSearchingValue
    
    @Binding var isSearching: Bool
    @Binding var searchText: String
    
    var comics: [Comic] = [
        .avangers,
        .starwars,
        .silversurfer,
        .deadpool,
        .captainamerica
    ]
    
    var characters: [Character] = [
        .spiderman,
        .wolverine,
        .ironman
    ]
    
    var results: [Result] = [
        .character(Character.ironman),
        .character(Character.wolverine),
        .comic(Comic.starwars),
        .character(Character.spiderman),
        .comic(Comic.avangers)
    ]
    
    enum Result: Hashable {
        case character(Character)
        case comic(Comic)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if !isSearching {
                SectionTitle("Explore")
                
                VStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(comics) { comic in
                                ComicCell(comic: comic)
                                    .frame(width: 120)
                            }
                        }
                    }
                    .padding(.top, 4)
                    
                    VStack(alignment: .leading) {
                        ForEach(characters) { character in
                            CharacterRow(character: character)
                            
                            Divider()
                                .edgesIgnoringSafeArea(.trailing)
                        }
                    }
                    .padding(.top)
                }
            } else {
                SectionTitle("Results")
                
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(results, id: \.self) { result in
                        switch result {
                        case .character(let character):
                            CharacterRow(character: character)
                        case .comic(let comic):
                            ComicRow(comic: comic)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding(.horizontal)
        .onChange(of: isSearchingValue) { newValue in
            isSearching = newValue
        }
    }
}

// MARK: - Previews

#if DEBUG
struct SearchTab_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchTab()
        }
    }
}
#endif
