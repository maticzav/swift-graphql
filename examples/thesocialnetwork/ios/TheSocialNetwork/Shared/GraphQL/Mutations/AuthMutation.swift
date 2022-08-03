import Foundation
import SwiftGraphQL

extension User {
    
    /// Returns a selection that lets you authenticate a user.
    static func login(username: String, password: String) -> Selection.Mutation<String?> {
        let selection = Selection.AuthPayload<String?> {
            try $0.on(
                authPayloadSuccess: Selection.AuthPayloadSuccess<String?> {
                    try $0.token()
                },
                authPayloadFailure: Selection.AuthPayloadFailure<String?> { _ in
                    nil
                }
            )
        }
        
        return Selection.Mutation<String?> {
            try $0.login(username: username, password: password, selection: selection)
        }
    }
    
    /// Returns a selection that modifies viewer's profile picture.
    ///
    /// - NOTE: To get the file parameter, upload a file to the CDN.
    static func changeProfilePicture(file: String) -> Selection.Mutation<User?> {
        Selection.Mutation<User?> {
            try $0.setProfilePicture(file: file, selection: User.selection.nullable)
        }
    }
}
