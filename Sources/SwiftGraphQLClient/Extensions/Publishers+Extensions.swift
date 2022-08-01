import Combine
import Foundation

// MARK: - OnEnd Opeartor

extension Publisher {
    
    /// An operator that triggers the handler when the publisher sends the completion event down to the subscriber.
    func onEnd(_ handler: @escaping () -> Void) -> Publishers.HandleEvents<Self> {
        self.handleEvents(receiveCompletion: { _ in handler() }, receiveCancel: handler)
    }
}

// MARK: - TakeUntil Publisher

extension Publisher {
    /// Takes upstream values until predicates a value.
    func takeUntil<Predicate: Publisher>(_ predicate: Predicate) -> Publishers.TakenUntilPublisher<Self, Predicate> {
        Publishers.TakenUntilPublisher<Self, Predicate>(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    /// A subscriber that takes upstream values for as long as predicate isn't met.
    /// Once the predicate fulfills, it sends a completion event down the stream.
    struct TakenUntilPublisher<Upstream: Publisher, Predicate: Publisher>: Publisher {
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure
        
        /// A function that tells whether the condition is met.
        private var predicate: Predicate
        
        /// Publisher emitting the values.
        private var upstream: Upstream
        
        // MARK: - Initializer
        
        init(upstream: Upstream, predicate: Predicate) {
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
    
    /// A subscription that emits upstream values downstream until predicate emits a value.
    final class TakeUntilSubscription<Downstream: Subscriber, Predicate: Publisher>: Subscription, Subscriber {
        
        typealias Input = Downstream.Input
        typealias Failure = Downstream.Failure
        
        /// Subscription that yields values streamed to the subscriber.
        private var subscription: Subscription?
        
        /// The subscriber we are forwarding values to.
        private var subscriber: Downstream
        
        /// Function telling whether the sought condition has been met.
        private var predicate: Predicate
        
        /// Tells whether the predicate has been met.
        private var closed: Bool = false
        
        private var cancellable: AnyCancellable?
        
        /// Tells how much events downstream has already requested from the upstream.
        private var demand: Subscribers.Demand
        
        init(subscriber: Downstream, predicate: Predicate) {
            self.subscriber = subscriber
            self.predicate = predicate
            self.demand = .none
        }
        
        // MARK: - Subscriber
        
        /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
        func receive(subscription: Subscription) {
            self.subscription = subscription
            
            self.cancellable = self.predicate
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { _ in
                    // We send the completion event downstream and cancel the
                    // upstream subscription once we've received any event.
                    self.subscriber.receive(completion: .finished)
                    self.subscription?.cancel()
                    self.subscription = nil
                    self.cancellable = nil
                })
            
            // Request the accumulated demand and drain it.
            if self.demand > 0 {
                self.subscription?.request(self.demand)
            }
            if self.demand < .unlimited {
                self.demand = .none
            }
        }
        
        func receive(_ input: Downstream.Input) -> Subscribers.Demand {
            // We simply forward all the values further down the chain.
            self.subscriber.receive(input)
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
            self.cancellable = nil
        }
    }
}
