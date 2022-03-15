// This file is heavily inspired by https://gist.github.com/emorydunn/e6b5c9803e5774c26926595a63b23f37.

import Combine
import Foundation
import GraphQLWebSocket

extension URLSession {
    /// Returns a publisher that wrapps a URLSessionWebSocketTask.
    func websocketTaskPublisher(for request: URLRequest) -> WebSocketTaskPublisher {
        WebSocketTaskPublisher(with: request, session: self)
    }
}

// MARK: - Publisher

public struct WebSocketTaskPublisher: WebSocket {
    
    public typealias Output = URLSessionWebSocketTask.Message
    public typealias Failure = Error
    
    /// The websocket task we are observing.
    let task: URLSessionWebSocketTask
    
    /// Creates a WebSocket task publisher from the provided URL and URL session.
    ///
    /// - NOTE: The provided url must use a `ws` or `wss` scheme!
    /// - Parameters:
    ///     - url: The WebSocket URL to connect to.
    ///     - session: The URLSession to use to create a task.
    public init(with request: URLRequest, session: URLSession = URLSession.shared) {
        self.task = session.webSocketTask(with: request)
    }
    
    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    public func receive<S>(subscriber: S) where S : Subscriber, Error == S.Failure, URLSessionWebSocketTask.Message == S.Input {
        let subscription = Subscription(task: self.task, target: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
    /// Sends a WebSocket message, receiving the result in a completion handler.
    public func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void) {
        self.task.send(message, completionHandler: completionHandler)
    }
    
    /// Stops the socket communcation.
    public func close() {
        task.cancel()
    }
}

extension WebSocketTaskPublisher {
    class Subscription<Target: Subscriber>: Combine.Subscription where Target.Input == Output, Target.Failure == Failure {
        
        let task: URLSessionWebSocketTask
        var target: Target?
        
        init(task: URLSessionWebSocketTask, target: Target) {
            self.task = task
            self.target = target
        }
        
        /// Requests new events from the publisher.
        func request(_ demand: Subscribers.Demand) {
            guard let target = target else { return }
            
            task.resume()
            self.listen(for: target, with: demand)
        }
        
        /// Cancels the subscription.
        func cancel() {
            task.cancel()
            self.target = nil
        }
        
        func listen(for target: Target, with demand: Subscribers.Demand) {
            var demand = demand
            
            self.task.receive { [weak self] result in
                switch result {
                case .success(let message):
                    demand -= 1
                    demand += target.receive(message)
                case .failure(let error):
                    target.receive(completion: .failure(error))
                }
                
                if demand > 0 {
                    self?.listen(for: target, with: demand)
                }
            }
        }
    }
}
