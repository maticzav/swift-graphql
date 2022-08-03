import Foundation
import SwiftGraphQL

extension User {
    /// Query fragment that fetches information about a user.
    static var selection = Selection.User<User> {
        let id = try $0.id()
        let username = try $0.username()
        let picture = try $0.picture()
        let isViewer = try $0.isViewer()
        
        if let picture = picture, let pictureURL = URL(string: picture) {
            return User(
                id: id,
                username: username,
                picture: pictureURL,
                isViewer: isViewer
            )
        }

        return User(id: id, username: username, isViewer: isViewer)
    }
    
    static var viewer = Selection.Query<User?> {
        try $0.viewer(selection: User.selection.nullable)
    }
}

