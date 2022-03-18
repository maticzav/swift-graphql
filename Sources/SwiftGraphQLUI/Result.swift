import Foundation
import SwiftGraphQLClient

/// Holds the current state of the query.
public struct Result<T: Decodable> {
    
    /// Current data received from the server.
    public var data: T? = nil
    
    /// Errors accumulated during the execution.
    public var errors: [CombinedError]? = nil
    
    /// Tells whether the client is currently performing the fetch operation.
    public var fetching: Bool = false
    
    /// Tells whether the data is outdated.
    public var stale: Bool = true
}
