import MarvelCore
import SwiftUI

struct HomeTab: View {
    var characters: [Character] = [
        .wolverine,
        .spiderman,
        .ironman
    ]
    
    var body: some View {
        NavigationView {
            List(characters) { character in
                NavigationLink {
                    CharacterView(character: character)
                        .navigationTitle(character.name)
                } label: {
                    CharacterRow(character: character)
                }
                .background(Material.thin)
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct HomeTab_Previews: PreviewProvider {
    static var previews: some View {
        HomeTab()
    }
}
