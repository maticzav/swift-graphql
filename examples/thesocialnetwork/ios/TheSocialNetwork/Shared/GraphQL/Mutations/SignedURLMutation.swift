import Foundation
import SwiftGraphQL

extension SignedURL {
    
    /// Returns a selection that lets authenticated user retrive the file upload URL.
    static func getSignedURL(extension ext: String, contentType: String) -> Selection.Mutation<SignedURL?> {
        Selection.Mutation<SignedURL?> {
            try $0.getProfilePictureSignedUrl(
                extension: ext,
                contentType: contentType,
                selection: SignedURL.selection.nullable
            )
        }
    }
}
