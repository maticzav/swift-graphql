import Combine
import Foundation
import GraphQL
import GraphQLWebSocket

public protocol WebSocketSession {
    
}

extension URLSession: WebSocketSession {}

/// Exchange that lets you perform GraphQL queries over WebSocket protocol.
///
/// - NOTE: By default WebSocketExchange only handles subscription operations
///         but you may configure it to handle all operations equally.
public class WebSocketExchange: Exchange {
    
    ///
    var session: WebSocketSession
    
    var client: GraphQLWebSocket
    
    
    
    init(session: WebSocketSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Methods
    
    func register(
        client: GraphQLClient,
        operations: AnyPublisher<Operation, Never>,
        next: ExchangeIO
    ) -> AnyPublisher<OperationResult, Never> {
        Empty<OperationResult, Never>().eraseToAnyPublisher()
    }
}


//session.webSocketTask(with: request)
