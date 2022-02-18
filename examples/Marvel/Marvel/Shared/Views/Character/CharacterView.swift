import MarvelCore
import SwiftUI

/// View that displays all details of a character.
struct CharacterView: View {
    @Environment(\.dismiss) var dismiss
    
    /// The character that we are presenting.
    var character: Character
    
    // MARK: - View
    
    var body: some View {
        VStack {
            NavigationBar {
                self.dismiss()
            } content: {}
            .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        AsyncImage(url: character.image) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFit()
                            } else {
                                Color.black
                            }
                        }
                        
                        .frame(maxWidth: .infinity)
                        .cornerRadius(16.0)
                    }
                    .padding()
                    
                    HStack {
                        Text(character.name)
                            .fontWeight(Font.Weight.heavy)
                            .font(.system(.title, design: .rounded).bold())
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("About")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(Font.Weight.heavy)
                            
                            Text(character.description)
                                .font(.system(.body, design: .rounded))
                        }
                        .foregroundColor(Color.white)
                    }
                    .padding()
                    .background(Material.ultraThin)
                    .cornerRadius(16.0)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
        .background(background)
    }
    
    @ViewBuilder
    var background: some View {
        AsyncImage(url: character.image) { phase in
            if let image = phase.image {
                image.resizable()
            } else {
                Color.black
            }
        }
        .scaledToFill()
        .edgesIgnoringSafeArea(.all)
        
        VisualEffectView(effect: UIBlurEffect(style: .dark))
            .edgesIgnoringSafeArea(.all)
        
    }
}

// MARK: - Previews

#if DEBUG
struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterView(character: Character.wolverine)
    }
}
#endif
