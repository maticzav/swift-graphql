import MarvelCore
import SwiftUI

/// Tab with all characters from the marvel universe.
struct CharactersTab: View {
    var characters: [Character] = [
        .wolverine,
        .spiderman,
        .ironman,
    ]
    
    // MARK: - View
    
    var body: some View {
        List {
            ForEach(characters) { character in
                NavigationLink {
                    CharacterView(character: character)
                        .navigationTitle(character.name)
                } label: {
                    CharacterRow(character: character)
                }
                
            }
        }
        .navigationTitle("Characters")
    }
}

struct HomeTab_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CharactersTab()
        }
    }
}
