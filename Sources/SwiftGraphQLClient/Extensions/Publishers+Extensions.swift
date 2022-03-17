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
    
    /// An operator that triggers the handler when the publisher sends the subscription down to the subscriber.
    func onEnd(_ handler: @escaping () -> Void) -> Publishers.StatefulPublisher<Self> {
        Publishers.StatefulPublisher<Self>(
            upstream: self,
            onStart: {},
            onEnd: handler
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
        
        /// Publisher emitting the values.
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
            // Wraps the actual subscriber inside a custom subscribers and subscribes to the upstream publisher with it.
            let sub = Subscriptions.StatefulSubscription(
                subscriber: subscriber,
                onStart: self.onStart,
                onEnd: self.onEnd
            )
            subscriber.receive(subscription: sub)
            self.upstream.receive(subscriber: sub)
        }
    }
}

extension Subscriptions {
    
    /// A subscription that republishes events from the upstream and watches
    /// for the construction and teardown of the pipeline.
    class StatefulSubscription<Downstream: Subscriber>: Subscription, Subscriber {
        
        typealias Input = Downstream.Input
        typealias Failure = Downstream.Failure
        

        /// Subscription that yields values we use to stream down.
        private var subscription: Subscription?
        
        /// The subscriber we are forwarding values to.
        private var subscriber: Downstream
        
        /// Cached demand.
        private var demand: Subscribers.Demand = .none
        
        /// A function that's triggered when the publisher establishes a connection with the subscriber.
        private var onStart: () -> Void
        
        /// A function called when the subscriber receives a completion event.
        private var onEnd: () -> Void
        

        init(
            subscriber: Downstream,
            onStart: @escaping () -> Void,
            onEnd: @escaping () -> Void
        ) {
            self.subscriber = subscriber
            self.onStart = onStart
            self.onEnd = onEnd
        }
        
        // MARK: - Subscriber

        func receive(subscription: Subscription) {
            self.subscription = subscription
            
            if self.demand > 0 {
                self.subscription?.request(self.demand)
                self.demand = .none
            }
            
            onStart()
        }

        func receive(_ input: Downstream.Input) -> Subscribers.Demand {
            self.subscriber.receive(input)
        }

        func receive(completion: Subscribers.Completion<Downstream.Failure>) {
            onEnd()
            self.subscriber.receive(completion: completion)
        }

        // MARK: - Subscription
        
        func request(_ demand: Subscribers.Demand) {
            guard let subscription = subscription else {
                self.demand += demand
                return
            }

            subscription.request(demand)
        }

        func cancel() {
            self.subscription?.cancel()
            self.subscription = nil
        }

    }
}
