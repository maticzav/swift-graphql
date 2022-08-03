import Foundation

struct Message: Identifiable, Equatable {
    var id: String
    
    /// The date when the message was sent.
    var createdAt: Date
    
    /// The content of the message.
    var message: String
    
    /// The profile that sent a given message.
    var sender: User
    
    /// Mock value that may be used in testng.
    static let preview = Message(
        id: "msg-mock",
        createdAt: Date.now,
        message: "Hello World!",
        sender: User.preview
    )
}
