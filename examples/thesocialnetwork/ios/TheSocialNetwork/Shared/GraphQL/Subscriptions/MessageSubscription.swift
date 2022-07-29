import Foundation
import SwiftGraphQL

extension Message {
    static let unread = Objects.Subscription.messages()
}
