import Combine
import Foundation

extension Publisher {
    
    /// An operator that triggers the handler when the publisher sends the subscription down to the subscriber.
    func onStart(_ handler: @escaping () -> Void) -> Publishers.StatefulPublisher<Self> {
        Publishers.StatefulPublisher<Self>(upstream: self, onStart: handler)
    }
    
    /// An operator that triggers the handler when the publisher sends the completion event down to the subscriber.
    func onEnd(_ handler: @escaping () -> Void) -> Publishers.StatefulPublisher<Self> {
        Publishers.StatefulPublisher<Self>(upstream: self, onEnd: handler)
    }
    
    /// An operator that triggers the handler everytime the publisher sends a new event.
    func onPush(_ handler: @escaping (Output) -> Void) -> Publishers.StatefulPublisher<Self> {
        Publishers.StatefulPublisher<Self>(upstream: self, onPush: handler)
    }
}

// MARK: - Stateful Publisher

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
        
        /// A function that's triggered on every receive call from the publisher.
        private var onPush: (Output) -> Void
        
        /// Publisher emitting the values.
        private var upstream: Upstream
        
        // MARK: - Initializer
        
        init(
            upstream: Upstream,
            onStart: @escaping () -> Void =  {},
            onEnd: @escaping () -> Void = {},
            onPush: @escaping (Output) -> Void = { _ in }
        ) {
            self.upstream = upstream
            self.onStart = onStart
            self.onEnd = onEnd
            self.onPush = onPush
        }
        
        // MARK: - Publisher
        
        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            // Wraps the actual subscriber inside a custom subscribers and subscribes to the upstream publisher with it.
            let sub = Subscriptions.StatefulSubscription(
                subscriber: subscriber,
                onStart: self.onStart,
                onEnd: self.onEnd,
                onPush: self.onPush
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
        
        /// A function that's triggered on every receive call from the publisher.
        private var onPush: (Downstream.Input) -> Void
        
        init(
            subscriber: Downstream,
            onStart: @escaping () -> Void,
            onEnd: @escaping () -> Void,
            onPush: @escaping (Downstream.Input) -> Void
        ) {
            self.subscriber = subscriber
            self.onStart = onStart
            self.onEnd = onEnd
            self.onPush = onPush
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
            self.onPush(input)
            return self.subscriber.receive(input)
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

// MARK: - TakeUntil Publisher

extension Publisher {
    
    /// Takes upstream values for as long as predicate isn't met. Once the predicate fulfills, it sends a completion event down the stream.
    func takeUntil(_ predicate: @escaping (Output) -> Bool) -> Publishers.TakenUntilPublisher<Self> {
        Publishers.TakenUntilPublisher<Self>(upstream: self, predicate: predicate)
    }
    
    /// Takes upstream values until the publisher emits a true value.
    func takeUntil(_ predicate: AnyPublisher<Bool, Never>) -> AnyPublisher<Output, Failure> {
        self.combineLatest(predicate.setFailureType(to: Failure.self))
            .takeUntil { value, p in p }
            .map { value, p in value }
            .eraseToAnyPublisher()
    }
}

extension Publishers {
    
    /// A subscriber that takes upstream values for as long as predicate isn't met.
    /// Once the predicate fulfills, it sends a completion event down the stream.
    struct TakenUntilPublisher<Upstream: Publisher>: Publisher {
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure
        
        /// A function that tells whether the condition is met.
        private var predicate: (Upstream.Output) -> Bool
        
        /// Publisher emitting the values.
        private var upstream: Upstream
        
        // MARK: - Initializer
        
        init(
            upstream: Upstream,
            predicate: @escaping (Upstream.Output) -> Bool
        ) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        // MARK: - Publisher
        
        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            
            // Wraps the actual subscriber inside a custom subscribers
            // and subscribes to the upstream publisher with it.
            let takeUntilSubscription = Subscriptions.TakeUntilSubscription(
                subscriber: subscriber,
                predicate: self.predicate
            )
            
            subscriber.receive(subscription: takeUntilSubscription)
            self.upstream.receive(subscriber: takeUntilSubscription)
        }
        
    }
}

extension Subscriptions {
    final class TakeUntilSubscription<Downstream: Subscriber>: Subscription, Subscriber {
        
        typealias Input = Downstream.Input
        typealias Failure = Downstream.Failure
        
        /// Subscription that yields values we use to stream down.
        private var subscription: Subscription?
        
        /// The subscriber we are forwarding values to.
        private var subscriber: Downstream
        
        /// Function telling whether the sought condition has been met.
        private var predicate: (Downstream.Input) -> Bool
        
        /// Tells whether the predicate has been met.
        private var closed: Bool = false
        
        /// Tells how much events downstream has already requested from the upstream.
        private var demand: Subscribers.Demand
        
        init(subscriber: Downstream, predicate: @escaping (Downstream.Input) -> Bool) {
            self.subscriber = subscriber
            self.predicate = predicate
            self.demand = .none
        }
        
        // MARK: - Subscriber
        
        func receive(subscription: Subscription) {
            self.subscription = subscription
            
            if self.demand > 0 {
                self.subscription?.request(self.demand)
            }
            
            if self.demand < .unlimited {
                self.demand = .none
            }
        }
        
        func receive(_ input: Downstream.Input) -> Subscribers.Demand {
            let result = self.predicate(input)
            
            // NOTE: Predicate may only evaluate once we have received some values from
            // the publisher (i.e. from the subscription). If there's no subscription,
            // the pipeline has been torn down and we don't have to worry about additional
            // events.
            guard !result else {
                if !closed {
                    self.subscriber.receive(completion: .finished)
                    self.closed = true
                }
                
                return .none
            }
            return self.subscriber.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<Downstream.Failure>) {
            self.closed = true
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
