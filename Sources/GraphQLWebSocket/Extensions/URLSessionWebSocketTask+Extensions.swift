// This file is heavily inspired by https://gist.github.com/emorydunn/e6b5c9803e5774c26926595a63b23f37.

import Combine
import Foundation

extension URLSession {
    
    /// Creates a new WebSocket task on this URLSession and returns
    /// a publisher that emits response received events.
    func websocketTaskPublisher(for request: URLRequest) -> WebSocketTaskPublisher {
        WebSocketTaskPublisher(request: request, session: self)
    }
}

// MARK: - Publisher

struct WebSocketTaskPublisher: Publisher {
    
    typealias Output = URLSessionWebSocketTask.Message
    typealias Failure = Error
    
    /// The websocket task we are observing.
    private let task: URLSessionWebSocketTask
    
    /// Creates a WebSocket task publisher from the provided request on the given URL session.
    ///
    /// - parameter request: The URL request to use as connection provider.
    /// - parameter session: The session to bundle the task with.
    ///
    /// - NOTE: The provided url must use a `ws` or `wss` scheme!
    init(request: URLRequest, session: URLSession) {
        self.task = session.webSocketTask(with: request)
    }
    
    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    func receive<S>(subscriber: S) where S : Subscriber, Error == S.Failure, URLSessionWebSocketTask.Message == S.Input {
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
    fileprivate class Subscription<Target: Subscriber>: Combine.Subscription where Target.Input == Output, Target.Failure == Failure {
        
        /// Task to use in the subscription.
        let task: URLSessionWebSocketTask
        
        /// Subscriber to this publisher.
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
