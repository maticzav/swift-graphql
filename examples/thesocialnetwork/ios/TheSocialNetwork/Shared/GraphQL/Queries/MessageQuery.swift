import Foundation
import SwiftGraphQL

extension Message {
    /// Query fragment that fetches information about a user.
    static var selection = Selection.Message<Message> {
        let id = try $0.id()
        let createdAt = try $0.createdAt()
        let message = try $0.message()
        let sender = try $0.sender(selection: User.selection)
        
        return Message(id: id, createdAt: createdAt, message: message, sender: sender)
    }
    
    /// Query that fetches the feed of messages from the server.
    static var feed = Selection.Query<[Message]> {
        try $0.feed(selection: Message.selection.list)
    }
}
