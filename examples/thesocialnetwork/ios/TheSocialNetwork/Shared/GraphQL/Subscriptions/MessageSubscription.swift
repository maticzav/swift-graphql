import Foundation
import SwiftGraphQL

extension Message {
    /// Returns a selection for subscription that tells how many messages have not been read yet.
    static let unread = Objects.Subscription.messages()
}
