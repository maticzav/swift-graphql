// This file is heavily inspired by https://betterprogramming.pub/build-a-chat-app-interface-with-swiftui-96609e605422.

import SwiftUI

/// A view that shows a chat message in a bubble.
struct ChatBubbleView: View {
    enum BubblePosition {
        case left
        case right
    }
    
    let position: BubblePosition
    let color : Color
    let message: String
    
    init(position: BubblePosition, color: Color, message: String) {
        self.position = position
        self.color = color
        self.message = message
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(message)
                .fontWeight(.semibold)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .foregroundColor(Color.white)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    Image(systemName: "arrowtriangle.left.fill")
                        .foregroundColor(color)
                        .rotationEffect(Angle(degrees: position == .left ? -50 : -130))
                        .offset(x: position == .left ? -5 : 5),
                    alignment: position == .left ? .bottomLeading : .bottomTrailing
                )
        }
        .padding(position == .left ? .leading : .trailing, 15)
        .padding(position == .right ? .leading : .trailing, 60)
        .frame(width: UIScreen.main.bounds.width, alignment: position == .left ? .leading : .trailing)
    }
}

struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 5) {
            ChatBubbleView(position: .left, color: Color.blue, message: "hey!")
            ChatBubbleView(position: .left, color: Color.blue, message: "are you there?")
            ChatBubbleView(position: .left, color: Color.blue, message: "reply ASAP!!!")
            ChatBubbleView(position: .right, color: Color.green, message: "hey! how are you doing?")
        }
        
    }
}
