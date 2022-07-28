import Foundation

struct SignedURL: Identifiable, Equatable {
    var id: String
    
    /// URL where the file should be uploaded.
    var uploadURL: URL
    
    /// URL where the file may be loaded from.
    var fileURL: URL
}
