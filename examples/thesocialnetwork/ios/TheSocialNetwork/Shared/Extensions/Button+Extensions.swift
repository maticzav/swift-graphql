import SwiftUI

private struct EnabledModifier: ViewModifier {
    @Environment(\.isEnabled) var isEnabled

    func body(content: Content) -> some View {
        content.opacity(isEnabled ? 1 : 0.6)
    }
}

// MARK: Primary

struct PrimaryBorderedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.modifier(Modifier())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.interactiveSpring(), value: configuration.isPressed)
    }

    private struct Modifier: ViewModifier {
        @Environment(\.isEnabled) var isEnabled

        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity)
                .labelStyle(LeadingIconLabelStyle())
                .font(.system(.body, design: .rounded).bold())
                .foregroundColor(Color.white)
                .modifier(EnabledModifier())
                .padding()
                .background(background())
        }

        @ViewBuilder
        func background() -> some View {
            ZStack {
                Capsule()
                    .fill(Color.blue)
                    .shadow(color: .black.opacity(0.15), radius: 48, x: 0, y: 16)
            }
        }
    }
}

private struct LeadingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.icon
                .frame(width: 16, height: 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            configuration.title
        }
    }
}

extension ButtonStyle where Self == PrimaryBorderedButtonStyle {
    static var primaryBordered: PrimaryBorderedButtonStyle { .init() }
}



struct ButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Button", action: { })
                .buttonStyle(.primaryBordered)

            Button {} label: {
                Label("Button", systemImage: "checkmark.circle.fill")
            }
            .buttonStyle(.primaryBordered)

            Button("Button", action: { })
                .buttonStyle(.primaryBordered)
                .disabled(true)

        }
        .padding()
    }
}
