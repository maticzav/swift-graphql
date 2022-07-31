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
    
    /// Takes upstream values for as long as predicate isn't met. Once the predicate fulfills, it sends a completion event down the stream.
    func takeUntilTrue(_ predicate: @escaping (Output) -> Bool) -> Publishers.TakenUntilPublisher<Self> {
        Publishers.TakenUntilPublisher<Self>(upstream: self, predicate: predicate)
    }
}

extension Publisher {
    /// Takes upstream values until the publisher emits a true value.
    func takeUntil(_ predicate: AnyPublisher<Bool, Never>) -> AnyPublisher<Output, Failure> {
        // We merge the publisher that immediately resolves with the predicate to make
        // sure values are emitted as soon as upstream starts sending values without waiting
        // for the predicate.
        let pp: AnyPublisher<Bool, Failure> = predicate
            .merge(with: Just(false))
            .setFailureType(to: Failure.self)
            .removeDuplicates()
            .eraseToAnyPublisher()
        
        let upstream = self.combineLatest(pp)
            .takeUntilTrue({ value, p in p })
            .map { value, p in value }
            
        return upstream.eraseToAnyPublisher()
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
