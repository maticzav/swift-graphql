import MarvelCore
import SwiftUI

/// Shows a preview of a character.
struct CharacterRow: View {
    
    /// The character that we are previewing.
    var character: Character
    
    // MARK: - View
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: character.image) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Color.gray.shimmer()
                }
        
            }
                .scaledToFit()
                .frame(width: 48, height: 48)
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(character.name)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                Text(character.description)
                    .font(.system(.body, design: .rounded))
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
    }
}

// MARK: - Previews

#if DEBUG
struct CharacterRow_Previews: PreviewProvider {
    static var previews: some View {
        CharacterRow(character: Character.wolverine)
            .padding()
    }
}
#endif
