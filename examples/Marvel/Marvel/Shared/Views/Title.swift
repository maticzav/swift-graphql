import SwiftUI

struct SectionTitle: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text).font(.system(.title3, design: .rounded).weight(.bold))
    }

}

// MARK: - Previews

#if DEBUG
struct Title_Previews: PreviewProvider {
    static var previews: some View {
        SectionTitle("Title")
    }
}
#endif
