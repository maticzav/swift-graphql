import MarvelCore
import SwiftUI

/// Shows a preview of a character.
struct CharacterRow: View {
    
    /// The character that we are previewing.
    var character: Character
    
    // MARK: - View
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: character.image)
                .scaledToFit()
                .frame(width: 48, height: 48)
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(character.name)
                    .font(Font.headline)
                Text(character.description)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Previews

#if DEBUG
struct CharacterRow_Previews: PreviewProvider {
    static var previews: some View {
        CharacterRow(character: Character.wolverine)
    }
}
#endif
