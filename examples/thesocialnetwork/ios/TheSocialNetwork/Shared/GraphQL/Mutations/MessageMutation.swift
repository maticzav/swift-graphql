import Foundation
import SwiftGraphQL

extension Message {
    
    /// Mutation that posts a message to the feed.
    static func post(message: String) -> Selection.Mutation<Message?> {
        Selection.Mutation<Message?> {
            try $0.message(message: message, selection: Message.selection.nullable)
        }
    }
}
