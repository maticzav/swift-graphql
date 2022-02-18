import MarvelCore
import SwiftUI

/// Shows a short preview of the comic.
struct ComicCell: View {
    
    var comic: Comic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            AsyncImage(url: comic.thumbnail) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Color.black
                }
            }
            .scaledToFit()
            .frame(height: 160)
            .cornerRadius(8.0)
            
            
            Text(comic.title)
                .lineLimit(1)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
        }
    }
}

// MARK: - Previews

#if DEBUG
struct ComicCell_Previews: PreviewProvider {
    static var previews: some View {
        ComicCell(comic: Comic.deadpool)
    }
}
#endif
