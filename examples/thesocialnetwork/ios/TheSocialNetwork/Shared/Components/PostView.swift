import Foundation
import SwiftUI

struct PostView: View {
    
    /// The content of the post.
    var message: String
    
    /// The user who created the post.
    var author: User
    
    /// The date of the post creation.
    var timestamp: Date
    
    private static var dateformatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    private var date: String {
        PostView.dateformatter.string(from: self.timestamp)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(message).font(.system(.body, design: .rounded))
            }
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .topLeading)
            
            Divider()
            
            HStack(alignment: .center) {
                AvatarView(url: author.picture)
                    .frame(width: 24, height: 24, alignment: .leading)
                    .padding(.trailing, 8)
                Text(author.username)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                
                Spacer()
                
                Text(date)
                    .font(.system(size: 14, design: .rounded))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 4).padding(.bottom, 8)
        .background(.regularMaterial).cornerRadius(8)
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 16) {
            PostView(message: "Hello World!", author: User.preview, timestamp: Date.now)
            PostView(message: "This is a super long post written to test out how the component handles posts that are super long and have lots of content!", author: User.preview, timestamp: Date.now)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top)
        .padding(.horizontal)
    }
}
