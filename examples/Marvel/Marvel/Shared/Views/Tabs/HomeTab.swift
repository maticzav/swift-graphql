import MarvelCore
import SwiftUI

struct HomeTab: View {
    var characters: [Character] = [
        .wolverine,
        .spiderman,
        .ironman
    ]
    
    var comics: [Comic] = [
        .avangers,
        .captainamerica,
        .deadpool
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 5) {
                Text("Characters")
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
                .frame(height: 200)
                
                Text("Comics")
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(comics) { comic in
                            NavigationLink {
                                ComicView(comic: comic)
                            } label: {
                                ComicCell(comic: comic)
                            }
                            
                        }
                    }
                    }
                .padding()
                
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("MarvelLogo")
                        .resizable()
                        .scaledToFit()
                }
            }
            
        }
    }
}

struct HomeTab_Previews: PreviewProvider {
    static var previews: some View {
        HomeTab()
    }
}
