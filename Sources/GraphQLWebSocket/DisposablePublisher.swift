import Combine
import Foundation
import GraphQL


/// A publisher that emits results and lets you dispose it.
public class DisposablePublisher<Output, Failure: Error>: Publisher {
    
    public typealias Output = Output
    public typealias Failure = Failure
    
    /// Reference to the internal subject that we use to emit new events to subscribers.
    fileprivate let subject = PassthroughSubject<Output, Failure>()
    
    /// Function that gets called when we dispose the publisher.
    private let onDispose: () -> Void
    
    init(onDispose: @escaping () -> Void) {
        self.onDispose = onDispose
    }
    
    // MARK: - Methods
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.subject.receive(subscriber: subscriber)
    }
    
    /// Completes the ongoing subscription related to the operation that created the publisher.
    public func dispose() {
        self.onDispose()
        self.subject.send(completion: .finished)
    }
}

// MARK: - Library Internal

extension DisposablePublisher: Subject {
    public func send(_ value: Output) {
        self.subject.send(value)
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        self.subject.send(completion: completion)
    }
    
    public func send(subscription: Subscription) {
        self.subject.send(subscription: subscription)
    }
}
