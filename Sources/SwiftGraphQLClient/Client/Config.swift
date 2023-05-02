import Foundation
import Logging

/// A structure that lets you configure 
public class ClientConfiguration {
    
    /// Logger that we use to communitcate state changes and events inside the client.
    open var logger: Logger = Logger(label: "graphql.client")
    
    public init() {
        // Certain built-in exchanges (e.g. `DebugExchange`) product `.debug` logs that require `.debug` log level to be visible. This makes sure that the expected functionality of all exchanges matches the actual functionality (e.g. "debug exchange actually prints messages in the console").
        self.logger.logLevel = .debug
    }
}
