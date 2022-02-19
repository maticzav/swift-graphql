import Foundation

/// An identifier associated with a comment.
public struct CommentId: Hashable {
    private var id: String
    
    public init(string id: String) {
        self.id = id
    }
    
    /// String representation of an id.
    public var string: String {
        self.id
    }
}

public struct Comment: Identifiable, Equatable {
    public var id: CommentId
    public var message: String
    public var author: User
    
    public init(id: CommentId, message: String, author: User) {
        self.id = id
        self.message = message
        self.author = author
    }
    
    /// A mock value that you may use in previews.
    public func preview(message: String) -> Comment {
        Comment(
            id: CommentId(string: "mck-\(message.hashValue)"),
            message: message,
            author: User.preview
        )
    }
}
