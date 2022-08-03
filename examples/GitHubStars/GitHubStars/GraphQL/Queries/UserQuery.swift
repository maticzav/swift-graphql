import Foundation
import SwiftGraphQL

extension User {
    static let selection = Selection.User<User> {
        let id = try $0.id()
        let username = try $0.login()
        let url = try $0.url()
        let avatar = try $0.avatarUrl()
        
        return User(id: id, username: username, url: url, avatar: avatar)
    }
    
    static let organization = Selection.Organization<User> {
        let id = try $0.id()
        let username = try $0.login()
        let url = try $0.url()
        let avatar = try $0.avatarUrl()
        
        return User(id: id, username: username, url: url, avatar: avatar)
    }
    
    static let viewer = Selection.Query<User> {
        try $0.viewer(selection: User.selection)
    }
}
