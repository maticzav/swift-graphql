import MarvelCore
import SwiftUI

/// Shows preview of a comic in a horizontal format.
struct ComicRow: View {
    
    /// Information about the displayed comic.
    var comic: Comic
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            AsyncImage(url: comic.thumbnail) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Color.gray
                        .aspectRatio(2 / 3, contentMode: .fit)
                        .shimmer()
                }
            }
            .scaledToFit()
            .frame(height: 120)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(comic.title)
                    .font(.system(.headline, design: .rounded))
                
                Text(comic.description)
                    .font(.system(.body, design: .rounded))
                    .lineLimit(2)
                
                HStack(alignment: .center, spacing: 8) {
                    Text("\(comic.pageCount) pages")
                        .font(.subheadline.bold())
                        .foregroundColor(Color.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    
                    if comic.starred || true {
                        Image(systemName: "star")
                    }
                }
                .padding(.top, 2)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct ComicRow_Previews: PreviewProvider {
    static var previews: some View {
        ComicRow(comic: Comic.starwars)
            .padding()
    }
}
#endif
