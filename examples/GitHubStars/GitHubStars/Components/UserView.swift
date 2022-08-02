import Foundation
import SwiftUI

struct UserView: View {
    
    /// The user whose profile the component is showing.
    var user: User
    
    var body: some View {
        HStack(alignment: .center) {
            AvatarView(url: user.avatar)
                .frame(width: 22, height: 22)
            
            Text(user.username)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
        }
    }
}

// MARK: - Previews

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: User.preview)
    }
}
