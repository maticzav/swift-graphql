import Foundation

/// Identifier associated with User structure.
public struct UserId: Hashable {
    private var id: String
    
    public init(string id: String) {
        self.id = id
    }
    
    /// String representation of the id.
    public var string: String {
        self.id
    }
    
    /// Mock value that you can use in previews.
    public static let preview = UserId(string: "mck-uid")
}

public struct User: Identifiable {
    public var id: UserId
    public var username: String
    public var avatar: URL
    
    public init(id: UserId, username: String, avatar: URL) {
        self.id = id
        self.username = username
        self.avatar = avatar
    }
    
    /// Mock value that you can use in previews.
    public static let preview = User(
        id: UserId.preview,
        username: "maticzav",
        avatar: URL(string: "https://avatars.githubusercontent.com/u/3924224")!
    )
}
