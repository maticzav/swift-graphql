import Foundation
import SwiftGraphQL

extension Date {
    
    /// Returns a subscription that periodically tells the current server time.
    static let serverTime = Objects.Subscription.time()
}
