import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

// MARK: - Previews

#if DEBUG
struct VisualEffectView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Image("MarvelBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                .edgesIgnoringSafeArea(.all)
            
            Image("MarvelBackground")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .cornerRadius(8.0)
                .shadow(color: Color.black, radius: 5, x: 0, y: 2)
        }
        
    }
}
#endif
