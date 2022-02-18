import MarvelCore
import SwiftUI

struct ComicView: View {
    
    @Environment(\.dismiss) var dismiss

    /// The displayed commic.
    var comic: Comic
    
    // MARK: - View
    
    var body: some View {
        VStack {
            NavigationBar {
                self.dismiss()
            } content: {}
            .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .center) {
                    AsyncImage(url: comic.thumbnail) { phase in
                        if let image = phase.image {
                            image.resizable()
                        } else {
                            Color.black
                        }
                    }
                        .scaledToFit()
                        .frame(height: 320)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .padding()
                    
                    
                    Text(comic.title)
                        .fontWeight(Font.Weight.heavy)
                        .font(.system(.title, design: .rounded).bold())
                        .foregroundColor(Color.white)
                        .padding(.bottom)
                    
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("About")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(Font.Weight.heavy)
                        
                        Text(comic.description)
                            .font(.system(.body, design: .rounded))
                    }
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Material.ultraThin)
                        .cornerRadius(16.0)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                    
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Extra")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.white)
                        
                        HStack(spacing: 3) {
                            self.meta(heading: "ISBN") {
                                Text(comic.isbn ?? "Unknown")
                            }
                            
                            self.meta(heading: "Pages") {
                                Text("\(comic.pageCount)")
                            }
                            
                            Spacer()
                        }
                        
                    }
                    .padding()
                    
                    
                    
                    Spacer()
                }
                .padding(.bottom, 120)
            }
        }
        .background(background)
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    var background: some View {
        AsyncImage(url: comic.thumbnail) { phase in
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
    
    @ViewBuilder
    func meta<Content: View>(heading: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(heading)
                .font(.system(size: 12, weight: .regular, design: .rounded))
            
            content()
                .font(.system(size: 16, weight: .heavy, design: .rounded))
        }
        .foregroundColor(Color.white)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Material.ultraThin)
        .cornerRadius(16.0)
    }
}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicView(comic: Comic.avangers)
    }
}
