import SwiftUI

struct NavigationBar<Content: View>: View {

    var label: LocalizedStringKey = "Back"
    
    /// Action when the back button is pressed.
    let action: () -> Void
    
    /// Extra content in the navigation bar.
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            Button(label, action: action).buttonStyle(CancelButtonStyle())

            Spacer()

            content
        }
    }
}

private struct CancelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(Color.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.black.opacity(0.08))
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.interactiveSpring(), value: configuration.isPressed)
    }
}
