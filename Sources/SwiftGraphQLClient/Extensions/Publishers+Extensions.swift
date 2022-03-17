import Combine
import Foundation

extension Publisher {
    
    /// An operator that triggers the handler when the publisher sends the subscription down to the subscriber.
    func onStart(_ handler: @escaping () -> Void) -> Publishers.StatefulPublisher<Self> {
        Publishers.StatefulPublisher<Self>(
            upstream: self,
            onStart: handler,
            onEnd: {}
        )
    }
}

extension Publishers {
    
    /// A subscriber that lets you listen for start and end events of the stream.
    ///
    /// Start triggers when the publisher initializes a subscription for a new subscriber (i.e. before any
    /// data flows down but after a subscriber is initialised).
    ///
    /// - NOTE: This publisher shouldn't be used on its own!
    final class StatefulPublisher<Upstream: Publisher>: Publisher {
 
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure
        
        /// A function that's triggered when the publisher establishes a connection with the subscriber.
        private var onStart: () -> Void
        
        /// A function called when the subscriber receives a completion event.
        private var onEnd: () -> Void
        
        private var upstream: Upstream
        
        // MARK: - Initializer
        
        init(
            upstream: Upstream,
            onStart: @escaping () -> Void,
            onEnd: @escaping () -> Void
        ) {
            self.upstream = upstream
            self.onStart = onStart
            self.onEnd = onEnd
        }
        
        // MARK: - Publisher
        
        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            self.upstream.receive(subscriber: subscriber)
            onStart()
        }
    }
}

//extension Subscriptions {
//    class StatefulSubscription<
//        Upstream: Subscription,
//        Downstream: Subscriber
//    >: Subscription {
//        
//        var subscriber: Downstream?
//        var upstream: Subscription
//        
//        init(subscriber: Downstream, upstream: Subscription) {
//            self.subscriber = subscriber
//            self.upstream = upstream
//        }
//        
//        func receive(subscription: Subscription) {
//            self.subscription = subscription
//        }
//        
//        func receive(_ input: T) -> Subscribers.Demand {
//            self.subscriber?.receive(input) ?? .none
//        }
//        
//        func receive(completion: Subscribers.Completion<E>) {
////            onEnd()
//            self.subscriber?.receive(completion: completion)
//        }
//        
//        func request(_ demand: Subscribers.Demand) {
//            self.upstream.request(demand)
//        }
//        
//        func cancel() {
//            self.upstream.cancel()
//        }
//        
//        
//    }
//}
