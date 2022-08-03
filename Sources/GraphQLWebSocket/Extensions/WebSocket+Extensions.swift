import Foundation
import Starscream

extension WebSocketClient {
    
    /// Disconnects from a socket using one of the close codes in the GraphQL WS specification.
    func disconnect(closeCode: CloseCode) {
        self.disconnect(closeCode: closeCode.rawValue)
    }
}
