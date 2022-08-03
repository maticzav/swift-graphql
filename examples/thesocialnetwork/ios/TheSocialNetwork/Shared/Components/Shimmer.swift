import Foundation
import SwiftUI

struct ShimmerBackground: View {
    var cornerRadius: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .foregroundColor(Color.gray)
            .transition(.opacity)
            .shimmer()
    }
}

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    
    /// How many seconds should it take for the light to pass from one side to the other.
    var duration = 1.5
    
    /// Tells whether shimmer is animating.
    var active = true
    
    func body(content: Content) -> some View {
        if active {
            content
                .modifier(AnimatedMask(phase: phase).animation(animation))
                .onAppear { phase = 0.8 }
        } else {
            content
        }
    }
    
    private var animation: Animation {
        Animation.linear(duration: duration).repeatForever(autoreverses: false)
    }
    
    private struct AnimatedMask: AnimatableModifier {
        var phase: CGFloat = 0
        
        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }
        
        func body(content: Content) -> some View {
            content.mask(GradientMask(phase: phase).scaleEffect(3))
        }
    }
    
    private struct GradientMask: View {
        let phase: CGFloat
        let centerColor = Color.white
        let edgeColor = Color.white.opacity(0.8)
        
        var body: some View {
            let gradient = Gradient(stops: [
                .init(color: self.edgeColor, location: self.phase),
                .init(color: self.centerColor, location: self.phase + 0.1),
                .init(color: self.edgeColor, location: self.phase + 0.2),
            ])
            
            LinearGradient(
                gradient: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension View {
    @ViewBuilder func shimmer(active: Bool = true, duration: Double = 1.5) -> some View {
        modifier(Shimmer(duration: duration, active: active))
    }
}

// MARK: - Previews

#if DEBUG
struct Shimmer_Previews: PreviewProvider {
    static var previews: some View {
        Capsule().foregroundColor(Color.blue).padding()
            .shimmer(active: true, duration: 2)
    }
}
#endif

