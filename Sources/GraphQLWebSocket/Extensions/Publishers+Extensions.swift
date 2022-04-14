// This code is heavily inspired by the answer from https://stackoverflow.com/questions/60624851/combine-framework-retry-after-delay/60627981#60627981.
import Combine
import Foundation

enum ShouldRetry {
    
    /// Publisher should do a retry but only after a given amount of time.
    case yes(after: Int)
    
    /// The publisher should foward the error.
    case no
}

// MARK: - Retry Publisher

extension Publisher {
    
    /**
     Retries the failed upstream publisher using the given retry behavior.
     
     - parameter after: Function that converts the retry count into a delay and tells whether the retry should happen.
     - parameter tolerance: The allowed tolerance in firing delayed events.
     - parameter scheduler: The scheduler that will be used for delaying the retry.
     - parameter options: Options relevant to the scheduler’s behavior.
     - returns: A publisher that attempts to recreate its subscription to a failed upstream publisher.
     */
    func retry<S>(
        after: @escaping (Int) -> ShouldRetry,
        tolerance: S.SchedulerTimeType.Stride? = nil,
        scheduler: S,
        options: S.SchedulerOptions? = nil
    ) -> AnyPublisher<Output, Failure> where S: Scheduler {
        return retry(
            count: 1,
            after: after,
            tolerance: tolerance,
            scheduler: scheduler,
            options: options
        )
    }
    
    private func retry<S>(
        count: Int,
        after: @escaping (Int) -> ShouldRetry,
        
        tolerance: S.SchedulerTimeType.Stride? = nil,
        scheduler: S,
        options: S.SchedulerOptions? = nil
    ) -> AnyPublisher<Output, Failure> where S: Scheduler {
        
        // This shouldn't happen, because we start with one and only add.
        // If it "does", finish immediately.
        guard count > 0 else {
            return Empty<Output, Failure>().eraseToAnyPublisher()
        }
        
        let shouldRetry = after(count)
        
        let wrapped = self.catch { error -> AnyPublisher<Output, Failure> in
            
            switch shouldRetry {
            case .yes(let delay):
                guard delay > 0 else {
                    // If there is no delay, we retry immediately.
                    return self.retry(
                        count: count + 1,
                        after: after,
                        tolerance: tolerance,
                        scheduler: scheduler,
                        options: options
                    )
                    .eraseToAnyPublisher()
                }
                
                return Just(())
                    .delay(for: .seconds(delay), tolerance: tolerance, scheduler: scheduler, options: options)
                    .flatMap {
                        return self.retry(
                            count: count + 1,
                            after: after,
                            tolerance: tolerance,
                            scheduler: scheduler,
                            options: options
                        )
                    }
                    .eraseToAnyPublisher()
            case .no:
                return Fail(error: error).eraseToAnyPublisher()
            }
            
        }
        
        return wrapped.eraseToAnyPublisher()
    }
    
}

// MARK: - Counting Publisher

extension Publisher {
    
    /// Returns a publisher that shares results from the upstream publisher with all subscribers and counts how many there are.
    func counter(
        onConnect: @escaping (Int) -> Void,
        onDisconnect: @escaping (Int) -> Void
    ) -> Publishers.CountingPublisher<Self> {
        Publishers.CountingPublisher(upstream: self, onConnect: onConnect, onDisconnect: onDisconnect)
    }
}

extension Publishers {
    
    /// Publisher that keeps track of the number of subscriptions and shares the values.
    class CountingPublisher<Upstream: Publisher>: Publisher {
        
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure
        
        /// Publisher that is emitting the values.
        private var upstream: Upstream
        
        /// Function that gets called when a new subscriber connects to the publisher.
        private var onConnect: (_ total: Int) -> Void
        
        /// Function that gets called when the subscription is released.
        private var onDisconnect: (_ remaining: Int) -> Void
        
        /// Number of connected subscribers.
        private var subscribersCount: Int = 0
        
        init(
            upstream: Upstream,
            onConnect: @escaping (Int) -> Void,
            onDisconnect: @escaping (Int) -> Void
        ) {
            self.upstream = upstream
            self.onConnect = onConnect
            self.onDisconnect = onDisconnect
        }
        
        // MARK: - Methods
        
        func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.subscribersCount += 1
            
            self.onConnect(self.subscribersCount)
            
            let subscription = Subscriptions.CountingSubscription(subscriber: subscriber) {
                self.subscribersCount -= 1
                self.onDisconnect(self.subscribersCount)
            }
            
            subscriber.receive(subscription: subscription)
            self.upstream.receive(subscriber: subscription)
        }
    }
    
}

extension Subscriptions {
    
    final class CountingSubscription<Downstream: Subscriber>: Subscription, Subscriber {
        
        typealias Input = Downstream.Input
        typealias Failure = Downstream.Failure
        
        /// Function that gets called when the subscription is released.
        private var onDisconnect: () -> Void
        
        // MARK: - State
        
        /// Subscription that yields values we use to stream down to our subscriber.
        private var subscription: Subscription?
        
        /// Tells how much events downstream has already requested from the upstream.
        private var demand: Subscribers.Demand = .none
        
        /// The subscriber of the publisher which we are forwarding to.
        private var subscriber: Downstream
        
        init(subscriber: Downstream, _ onDisconnect: @escaping () -> Void) {
            self.subscriber = subscriber
            self.onDisconnect = onDisconnect
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
            
            self.onDisconnect()
        }
    }
    
}
