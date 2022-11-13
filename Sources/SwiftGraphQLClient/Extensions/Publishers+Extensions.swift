import Combine
import Foundation

// MARK: - TakeUntil Publisher

extension Publisher {
    /// Takes upstream values until predicates a value.
    func takeUntil<Terminator: Publisher>(_ terminator: Terminator) -> Publishers.TakenUntilPublisher<Self, Terminator> {
        Publishers.TakenUntilPublisher<Self, Terminator>(upstream: self, terminator: terminator)
    }

    /// Takes the first emitted value and completes or throws an error
    func first() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    continuation.resume(with: .success(value))
                }
        }
    }
}

extension Publisher where Failure == Never {
    /// Takes the first emitted value and completes or throws an error
    func first() async -> Output {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = first()
                .sink { _ in
                    cancellable?.cancel()
                } receiveValue: { value in
                    continuation.resume(with: .success(value))
                }
        }
    }
}

extension Publishers {
    
    /// A subscriber that takes upstream values until terminator emits a value.
    struct TakenUntilPublisher<Upstream: Publisher, Terminator: Publisher>: Publisher {
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure
        
        /// A function that tells whether the condition is met.
        private var terminator: Terminator
        
        /// Publisher emitting the values.
        private var upstream: Upstream
        
        // MARK: - Initializer
        
        init(upstream: Upstream, terminator: Terminator) {
            self.upstream = upstream
            self.terminator = terminator
        }
        
        // MARK: - Publisher
        
        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            
            // Wraps the actual subscriber inside a custom subscribers
            // and subscribes to the upstream publisher with it.
            let takeUntilSubscription = Subscriptions.TakeUntilSubscription(
                subscriber: subscriber,
                terminator: self.terminator
            )
            
            subscriber.receive(subscription: takeUntilSubscription)
            self.upstream.receive(subscriber: takeUntilSubscription)
        }
        
    }
}

extension Subscriptions {
    
    /// A subscription that emits upstream values downstream until predicate emits a value.
    final class TakeUntilSubscription<Downstream: Subscriber, Terminator: Publisher>: Subscription, Subscriber {
        
        typealias Input = Downstream.Input
        typealias Failure = Downstream.Failure
        
        /// Subscription that yields values streamed to the subscriber.
        private var subscription: Subscription?
        
        /// Tells how much events downstream has already requested from the upstream.
        private var demand: Subscribers.Demand
        
        /// The subscriber we are forwarding values to.
        private var subscriber: Downstream
        
        /// Function telling whether the sought condition has been met.
        private var terminator: Terminator
        
        /// Cancellable reference to the terminator sink.
        private var cancellable: AnyCancellable?

        init(subscriber: Downstream, terminator: Terminator) {
            self.subscriber = subscriber
            self.terminator = terminator
            self.demand = .none
        }
        
        // MARK: - Subscriber
        
        /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
        func receive(subscription: Subscription) {
            self.subscription = subscription
            
            self.cancellable = self.terminator
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { [weak self] _ in
                    guard let _ = self?.cancellable else {
                        return
                    }

                    // We send the completion event downstream and cancel the
                    // upstream subscription once we've received any event from the predicate.
                    self?.subscriber.receive(completion: .finished)
                    self?.cancel()
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
            self.subscriber.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<Downstream.Failure>) {
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
            
            self.cancellable?.cancel()
            self.cancellable = nil
        }
    }
}
