// This code is heavily inspired by the answer from https://stackoverflow.com/questions/60624851/combine-framework-retry-after-delay/60627981#60627981.
import Combine
import Foundation

enum ShouldRetry {
    
    /// Publisher should do a retry but only after a given amount of time.
    case yes(after: Int)
    
    /// The publisher should foward the error.
    case no
}

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
