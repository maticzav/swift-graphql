import SwiftUI

enum ToastKind {
    case info
    case success
    case error
}

struct Toast: Equatable {
    
    /// Label placed on the toast value.
    var label: Text
    
    /// Presentation mode of the toast.
    var kind: ToastKind

    init<S: StringProtocol>(label: S, kind: ToastKind) {
        self.label = Text(label)
        self.kind = kind
    }

    /// Toast view used to present a postive notification.
    fileprivate static func success(_ label: Text) -> some View {
        ToastView {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                label
            }
            .font(.subheadline.bold())
            .foregroundColor(.white)
        } background: {
            Capsule()
                .foregroundColor(.green)
                .shadow(color: Color.black.opacity(0.08), radius: 5)
        }
    }

    /// Toast view used to present a warning to the user.
    fileprivate static func error(_ label: Text) -> some View {
        ToastView {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                label
            }
            .font(.subheadline.bold())
            .foregroundColor(.white)
        } background: {
            Capsule()
                .foregroundColor(.red)
                .shadow(color: Color.black.opacity(0.08), radius: 5)
        }
    }

    /// Toast view used to present general information.
    fileprivate static func info(_ label: Text) -> some View {
        ToastView {
            label
            .font(.subheadline.bold())
            .foregroundColor(.white)
        } background: {
            Capsule()
                .foregroundColor(.blue)
                .shadow(color: Color.black.opacity(0.08), radius: 5)
        }
    }
}

struct ToastView<Label: View, Background: View>: View {
    @ViewBuilder var label: Label
    @ViewBuilder var background: Background

    var body: some View {
        label
            .padding(8)
            .padding(.horizontal, 4)
            .background { background }
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding(.horizontal)
    }
}

final class ToastCoordinator: ObservableObject {
    @Published var toast: Toast?

    fileprivate init() {
        // Auto-clear after 2 seconds
        $toast
            .compactMap { $0 }
            .debounce(for: 2, scheduler: DispatchQueue.global(qos: .unspecified))
            .map { _ in nil }
            .receive(on: DispatchQueue.main)
            .assign(to: &$toast)
    }
}

/// SwiftUI component that should be placed in the root view.
struct ToastContainer<Content: View>: View {
    @ViewBuilder var content: Content

    /// Coordinator that manages toasts.
    @StateObject var coordinator = ToastCoordinator()

    var body: some View {
        content
            .environmentObject(coordinator)
            .overlay(alignment: .top) {
                VStack {
                    if let toast = coordinator.toast {
                        Group {
                            switch toast.kind {
                            case .info:
                                Toast.info(toast.label)
                            case .error:
                                Toast.error(toast.label)
                            case .success:
                                Toast.success(toast.label)
                            }
                        }
                        .onTapGesture {
                            coordinator.toast = nil
                        }
                    }
                }
                .animation(.spring(), value: coordinator.toast)
            }
    }
}

// MARK: - Previews

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            VStack {
                Toast.info(Text("Message"))
                Toast.success(Text("Message"))
                Toast.error(Text("Message"))
            }
            VStack {
                Toast.info(Text("Message"))
                Toast.success(Text("Message"))
                Toast.error(Text("Message"))
            }
            .environment(\.colorScheme, .dark)
        }
    }
}
