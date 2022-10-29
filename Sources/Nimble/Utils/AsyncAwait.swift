#if !os(WASI)

import CoreFoundation
import Dispatch
import Foundation

private let timeoutLeeway = DispatchTimeInterval.milliseconds(1)
private let pollLeeway = DispatchTimeInterval.milliseconds(1)

internal struct AsyncAwaitTrigger {
    let timeoutSource: DispatchSourceTimer
    let actionSource: DispatchSourceTimer?
    let start: () async throws -> Void
}

/// Factory for building fully configured AwaitPromises and waiting for their results.
///
/// This factory stores all the state for an async expectation so that Await doesn't
/// doesn't have to manage it.
internal class AsyncAwaitPromiseBuilder<T> {
    let awaiter: Awaiter
    let waitLock: WaitLock
    let trigger: AsyncAwaitTrigger
    let promise: AwaitPromise<T>

    internal init(
        awaiter: Awaiter,
        waitLock: WaitLock,
        promise: AwaitPromise<T>,
        trigger: AsyncAwaitTrigger) {
            self.awaiter = awaiter
            self.waitLock = waitLock
            self.promise = promise
            self.trigger = trigger
    }

    func timeout(_ timeoutInterval: DispatchTimeInterval, forcefullyAbortTimeout: DispatchTimeInterval) -> Self {
        /// = Discussion =
        ///
        /// There's a lot of technical decisions here that is useful to elaborate on. This is
        /// definitely more lower-level than the previous NSRunLoop based implementation.
        ///
        ///
        /// Why Dispatch Source?
        ///
        ///
        /// We're using a dispatch source to have better control of the run loop behavior.
        /// A timer source gives us deferred-timing control without having to rely as much on
        /// a run loop's traditional dispatching machinery (eg - NSTimers, DefaultRunLoopMode, etc.)
        /// which is ripe for getting corrupted by application code.
        ///
        /// And unlike `dispatch_async()`, we can control how likely our code gets prioritized to
        /// executed (see leeway parameter) + DISPATCH_TIMER_STRICT.
        ///
        /// This timer is assumed to run on the HIGH priority queue to ensure it maintains the
        /// highest priority over normal application / test code when possible.
        ///
        ///
        /// Run Loop Management
        ///
        /// In order to properly interrupt the waiting behavior performed by this factory class,
        /// this timer stops the main run loop to tell the waiter code that the result should be
        /// checked.
        ///
        /// In addition, stopping the run loop is used to halt code executed on the main run loop.
        trigger.timeoutSource.schedule(
            deadline: DispatchTime.now() + timeoutInterval,
            repeating: .never,
            leeway: timeoutLeeway
        )
        trigger.timeoutSource.setEventHandler {
            guard self.promise.asyncResult.isIncomplete() else { return }
            let timedOutSem = DispatchSemaphore(value: 0)
            let semTimedOutOrBlocked = DispatchSemaphore(value: 0)
            semTimedOutOrBlocked.signal()
            DispatchQueue.main.async {
                if semTimedOutOrBlocked.wait(timeout: .now()) == .success {
                    timedOutSem.signal()
                    semTimedOutOrBlocked.signal()
                    self.promise.resolveResult(.timedOut)
                }
            }
            // potentially interrupt blocking code on run loop to let timeout code run
            let now = DispatchTime.now() + forcefullyAbortTimeout
            let didNotTimeOut = timedOutSem.wait(timeout: now) != .success
            let timeoutWasNotTriggered = semTimedOutOrBlocked.wait(timeout: .now()) == .success
            if didNotTimeOut && timeoutWasNotTriggered {
                self.promise.resolveResult(.blockedRunLoop)
            }
        }
        return self
    }

    /// Blocks for an asynchronous result.
    ///
    /// @discussion
    /// This function cannot be nested. This is because this function (and it's related methods)
    /// coordinate through the main run loop. Tampering with the run loop can cause undesirable behavior.
    ///
    /// This method will return an AwaitResult in the following cases:
    ///
    /// - The main run loop is blocked by other operations and the async expectation cannot be
    ///   be stopped.
    /// - The async expectation timed out
    /// - The async expectation succeeded
    /// - The async expectation raised an unexpected exception (objc)
    /// - The async expectation raised an unexpected error (swift)
    ///
    /// The returned AwaitResult will NEVER be .incomplete.
    @MainActor
    func wait(_ fnName: String = #function, file: FileString = #file, line: UInt = #line) async -> PollResult<T> {
        waitLock.acquireWaitingLock(
            fnName,
            file: file,
            line: line)

        defer {
            self.waitLock.releaseWaitingLock()
        }
        do {
            try await self.trigger.start()
        } catch let error {
            self.promise.resolveResult(.errorThrown(error))
        }
        self.trigger.timeoutSource.resume()
        while self.promise.asyncResult.isIncomplete() {
            await Task.yield()
        }

        self.trigger.timeoutSource.cancel()
        if let asyncSource = self.trigger.actionSource {
            asyncSource.cancel()
        }

        return promise.asyncResult
    }
}

extension Awaiter {
    func performBlock<T>(
        file: FileString,
        line: UInt,
        _ closure: @escaping (@escaping (T) -> Void) async throws -> Void
        ) async -> AsyncAwaitPromiseBuilder<T> {
            let promise = AwaitPromise<T>()
            let timeoutSource = createTimerSource(timeoutQueue)
            var completionCount = 0
            let trigger = AsyncAwaitTrigger(timeoutSource: timeoutSource, actionSource: nil) {
                try await closure { result in
                    completionCount += 1
                    if completionCount < 2 {
                        promise.resolveResult(.completed(result))
                    } else {
                        fail("waitUntil(..) expects its completion closure to be only called once",
                             file: file, line: line)
                    }
                }
            }

            return AsyncAwaitPromiseBuilder(
                awaiter: self,
                waitLock: waitLock,
                promise: promise,
                trigger: trigger)
    }

    func poll<T>(_ pollInterval: DispatchTimeInterval, closure: @escaping () throws -> T?) async -> AsyncAwaitPromiseBuilder<T> {
        let promise = AwaitPromise<T>()
        let timeoutSource = createTimerSource(timeoutQueue)
        let asyncSource = createTimerSource(asyncQueue)
        let trigger = AsyncAwaitTrigger(timeoutSource: timeoutSource, actionSource: asyncSource) {
            let interval = pollInterval
            asyncSource.schedule(deadline: .now(), repeating: interval, leeway: pollLeeway)
            asyncSource.setEventHandler {
                do {
                    if let result = try closure() {
                        promise.resolveResult(.completed(result))
                    }
                } catch let error {
                    promise.resolveResult(.errorThrown(error))
                }
            }
            asyncSource.resume()
        }

        return AsyncAwaitPromiseBuilder(
            awaiter: self,
            waitLock: waitLock,
            promise: promise,
            trigger: trigger)
    }
}

internal func pollBlock(
    pollInterval: DispatchTimeInterval,
    timeoutInterval: DispatchTimeInterval,
    file: FileString,
    line: UInt,
    fnName: String = #function,
    expression: @escaping () throws -> Bool) async -> PollResult<Bool> {
        let awaiter = NimbleEnvironment.activeInstance.awaiter
        let result = await awaiter.poll(pollInterval) { () throws -> Bool? in
            if try expression() {
                return true
            }
            return nil
        }
            .timeout(timeoutInterval, forcefullyAbortTimeout: timeoutInterval.divided)
            .wait(fnName, file: file, line: line)

        return result
}

#endif // #if !os(WASI)
