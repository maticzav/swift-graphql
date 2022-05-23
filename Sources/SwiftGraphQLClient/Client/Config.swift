import Foundation
import os

/// A structure that lets you configure 
public struct ClientConfiguration {
    
    /// Logger that we use to communitcate state changes and events inside the client.
    public var logger: Logger = Logger(subsystem: "graphql", category: "client")
    
    public init() {}
}
