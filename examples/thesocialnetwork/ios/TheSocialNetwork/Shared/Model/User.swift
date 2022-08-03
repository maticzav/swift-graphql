import Foundation

struct User: Identifiable, Equatable {
    var id: String
    
    /// Public name of the user.
    var username: String
    
    /// Profile picture of the user.
    var picture: URL?
    
    /// Tells whether the observed user is the viewer.
    var isViewer: Bool
    
    /// A mock value that may be used in testing.
    static let preview = User(
        id: "usr-preview",
        username: "maticzav",
        picture: URL(string: "https://avatars.githubusercontent.com/u/3924224")!,
        isViewer: true
    )
}
