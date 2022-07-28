import Foundation
import SwiftGraphQL

extension SignedURL {
    /// Selection that may be used to query a signed URL from the server.
    static let selection = Selection.SignedUrl<SignedURL> {
        let id = try $0.fileId()
        let uploadURLRaw = try $0.uploadUrl()
        let fileURLRaw = try $0.fileUrl()
        
        guard let uploadURL = URL(string: uploadURLRaw) else {
            throw SignedURLDecodingError.invalidUploadURL
        }
        
        guard let fileURL = URL(string: fileURLRaw) else {
            throw SignedURLDecodingError.invalidFileURL
        }
        
        return SignedURL(id: id, uploadURL: uploadURL, fileURL: fileURL)
    }
}

enum SignedURLDecodingError: Error {
    case invalidUploadURL
    case invalidFileURL
}
