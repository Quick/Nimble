#if !os(WASI)

#if canImport(CoreFoundation)
import CoreFoundation
#endif
import Dispatch
import Foundation

private let timeoutLeeway = NimbleTimeInterval.milliseconds(1)
private let pollLeeway = NimbleTimeInterval.milliseconds(1)

/// Stores debugging information about callers
internal struct WaitingInfo: CustomStringConvertible, Sendable {
    let name: String
    let file: FileString
    let lineNumber: UInt

    var description: String {
        return "\(name) at \(file):\(lineNumber)"
    }
}

internal protocol WaitLock {
    func acquireWaitingLock(_ fnName: String, file: FileString, line: UInt)
    func releaseWaitingLock()
    func isWaitingLocked() -> Bool
}

internal final class AssertionWaitLock: WaitLock, @unchecked Sendable {
    private var currentWaiter: WaitingInfo?
    private let lock = NSRecursiveLock()

    init() { }

    func acquireWaitingLock(_ fnName: String, file: FileString, line: UInt) {
        lock.lock()
        defer { lock.unlock() }
        let info = WaitingInfo(name: fnName, file: file, lineNumber: line)
        nimblePrecondition(
            currentWaiter == nil,
            "InvalidNimbleAPIUsage",
            """
            Nested async expectations are not allowed to avoid creating flaky tests.

            The call to
            \t\(info)
            triggered this exception because
            \t\(currentWaiter!)
            is currently managing the main run loop.
            """
        )
        currentWaiter = info
    }

    func isWaitingLocked() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return currentWaiter != nil
    }

    func releaseWaitingLock() {
        lock.lock()
        defer { lock.unlock() }
        currentWaiter = nil
    }
}

internal enum PollResult<T> {
    /// Incomplete indicates None (aka - this value hasn't been fulfilled yet)
    case incomplete
    /// TimedOut indicates the result reached its defined timeout limit before returning
    case timedOut
    /// BlockedRunLoop indicates the main runloop is too busy processing other blocks to trigger
    /// the timeout code.
    ///
    /// This may also mean the async code waiting upon may have never actually ran within the
    /// required time because other timers & sources are running on the main run loop.
    case blockedRunLoop
    /// The async block successfully executed and returned a given result
    case completed(T)
    /// When a Swift Error is thrown
    case errorThrown(Error)
    /// When an Objective-C Exception is raised
    case raisedException(NSException)

    func isIncomplete() -> Bool {
        switch self {
        case .incomplete: return true
        default: return false
        }
    }

    func isCompleted() -> Bool {
        switch self {
        case .completed: return true
        default: return false
        }
    }
}

internal enum PollStatus {
    case finished(Bool)
    case incomplete
}

/// Holds the resulting value from an asynchronous expectation.
/// This class is thread-safe at receiving a "response" to this promise.
internal final class AwaitPromise<T> {
    private(set) internal var asyncResult: PollResult<T> = .incomplete
    private var signal: DispatchSemaphore

    init() {
        signal = DispatchSemaphore(value: 1)
    }

    deinit {
        signal.signal()
    }

    /// Resolves the promise with the given result if it has not been resolved. Repeated calls to
    /// this method will resolve in a no-op.
    ///
    /// @returns a Bool that indicates if the async result was accepted or rejected because another
    ///          value was received first.
    @discardableResult
    func resolveResult(_ result: PollResult<T>) -> Bool {
        if signal.wait(timeout: .now()) == .success {
            self.asyncResult = result
            return true
        } else {
            return false
        }
    }
}

internal struct PollAwaitTrigger {
    let timeoutSource: DispatchSourceTimer
    let actionSource: DispatchSourceTimer?
    let start: () throws -> Void
}

/// Factory for building fully configured AwaitPromises and waiting for their results.
///
/// This factory stores all the state for an async expectation so that Await doesn't
/// doesn't have to manage it.
internal class AwaitPromiseBuilder<T> {
    let awaiter: Awaiter
    let waitLock: WaitLock
    let trigger: PollAwaitTrigger
    let promise: AwaitPromise<T>

    internal init(
        awaiter: Awaiter,
        waitLock: WaitLock,
        promise: AwaitPromise<T>,
        trigger: PollAwaitTrigger) {
            self.awaiter = awaiter
            self.waitLock = waitLock
            self.promise = promise
            self.trigger = trigger
    }

    func timeout(_ timeoutInterval: NimbleTimeInterval, forcefullyAbortTimeout: NimbleTimeInterval) -> Self {
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
            deadline: DispatchTime.now() + timeoutInterval.dispatchTimeInterval,
            repeating: .never,
            leeway: timeoutLeeway.dispatchTimeInterval
        )
        trigger.timeoutSource.setEventHandler {
            guard self.promise.asyncResult.isIncomplete() else { return }
            let timedOutSem = DispatchSemaphore(value: 0)
            let semTimedOutOrBlocked = DispatchSemaphore(value: 0)
            semTimedOutOrBlocked.signal()
            #if canImport(CoreFoundation)
            let runLoop = CFRunLoopGetMain()
            #if canImport(Darwin)
                let runLoopMode = CFRunLoopMode.defaultMode.rawValue
            #else
                let runLoopMode = kCFRunLoopDefaultMode
            #endif
            CFRunLoopPerformBlock(runLoop, runLoopMode) {
                if semTimedOutOrBlocked.wait(timeout: .now()) == .success {
                    timedOutSem.signal()
                    semTimedOutOrBlocked.signal()
                    if self.promise.resolveResult(.timedOut) {
                        CFRunLoopStop(CFRunLoopGetMain())
                    }
                }
            }
            // potentially interrupt blocking code on run loop to let timeout code run
            CFRunLoopStop(runLoop)
            #else
            let runLoop = RunLoop.main
            runLoop.perform(inModes: [.default], block: {
                if semTimedOutOrBlocked.wait(timeout: .now()) == .success {
                    timedOutSem.signal()
                    semTimedOutOrBlocked.signal()
                    if self.promise.resolveResult(.timedOut) {
                        RunLoop.main._stop()
                    }
                }
            })
            // potentially interrupt blocking code on run loop to let timeout code run
            runLoop._stop()
            #endif
            let now = DispatchTime.now() + forcefullyAbortTimeout.dispatchTimeInterval
            let didNotTimeOut = timedOutSem.wait(timeout: now) != .success
            let timeoutWasNotTriggered = semTimedOutOrBlocked.wait(timeout: .now()) == .success
            if didNotTimeOut && timeoutWasNotTriggered {
                if self.promise.resolveResult(.blockedRunLoop) {
                    #if canImport(CoreFoundation)
                    CFRunLoopStop(CFRunLoopGetMain())
                    #else
                    RunLoop.main._stop()
                    #endif
                }
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
    /// The returned PollResult will NEVER be .incomplete.
    func wait(_ fnName: String = #function, file: FileString = #file, line: UInt = #line) -> PollResult<T> {
        waitLock.acquireWaitingLock(
            fnName,
            file: file,
            line: line)

        let capture = NMBExceptionCapture(handler: ({ exception in
            _ = self.promise.resolveResult(.raisedException(exception))
        }), finally: ({
            self.waitLock.releaseWaitingLock()
        }))
        capture.tryBlock {
            do {
                try self.trigger.start()
            } catch let error {
                _ = self.promise.resolveResult(.errorThrown(error))
            }
            self.trigger.timeoutSource.resume()
            while self.promise.asyncResult.isIncomplete() {
                // Stopping the run loop does not work unless we run only 1 mode
                _ = RunLoop.current.run(mode: .default, before: .distantFuture)
            }

            self.trigger.timeoutSource.cancel()
            if let asyncSource = self.trigger.actionSource {
                asyncSource.cancel()
            }
        }

        return promise.asyncResult
    }
}

internal class Awaiter {
    let waitLock: WaitLock
    let timeoutQueue: DispatchQueue
    let asyncQueue: DispatchQueue

    internal init(
        waitLock: WaitLock,
        asyncQueue: DispatchQueue,
        timeoutQueue: DispatchQueue) {
            self.waitLock = waitLock
            self.asyncQueue = asyncQueue
            self.timeoutQueue = timeoutQueue
    }

    internal func createTimerSource(_ queue: DispatchQueue) -> DispatchSourceTimer {
        return DispatchSource.makeTimerSource(flags: .strict, queue: queue)
    }

    func performBlock<T>(
        file: FileString,
        line: UInt,
        _ closure: @escaping (@escaping (T) -> Void) throws -> Void
        ) -> AwaitPromiseBuilder<T> {
            let promise = AwaitPromise<T>()
            let timeoutSource = createTimerSource(timeoutQueue)
            var completionCount = 0
            let trigger = PollAwaitTrigger(timeoutSource: timeoutSource, actionSource: nil) {
                try closure { result in
                    completionCount += 1
                    if completionCount < 2 {
                        func completeBlock() {
                            if promise.resolveResult(.completed(result)) {
                                #if canImport(CoreFoundation)
                                CFRunLoopStop(CFRunLoopGetMain())
                                #else
                                RunLoop.main._stop()
                                #endif
                            }
                        }

                        if Thread.isMainThread {
                            completeBlock()
                        } else {
                            DispatchQueue.main.async { completeBlock() }
                        }
                    } else {
                        fail("waitUntil(..) expects its completion closure to be only called once",
                             file: file, line: line)
                    }
                }
            }

            return AwaitPromiseBuilder(
                awaiter: self,
                waitLock: waitLock,
                promise: promise,
                trigger: trigger)
    }

    func poll<T>(_ pollInterval: NimbleTimeInterval, closure: @escaping () throws -> T?) -> AwaitPromiseBuilder<T> {
        let promise = AwaitPromise<T>()
        let timeoutSource = createTimerSource(timeoutQueue)
        let asyncSource = createTimerSource(asyncQueue)
        let trigger = PollAwaitTrigger(timeoutSource: timeoutSource, actionSource: asyncSource) {
            let interval = pollInterval
            asyncSource.schedule(
                deadline: .now(),
                repeating: interval.dispatchTimeInterval,
                leeway: pollLeeway.dispatchTimeInterval
            )
            asyncSource.setEventHandler {
                do {
                    if let result = try closure() {
                        if promise.resolveResult(.completed(result)) {
                            #if canImport(CoreFoundation)
                            CFRunLoopStop(CFRunLoopGetCurrent())
                            #else
                            RunLoop.current._stop()
                            #endif
                        }
                    }
                } catch let error {
                    if promise.resolveResult(.errorThrown(error)) {
                        #if canImport(CoreFoundation)
                        CFRunLoopStop(CFRunLoopGetCurrent())
                        #else
                        RunLoop.current._stop()
                        #endif
                    }
                }
            }
            asyncSource.resume()
        }

        return AwaitPromiseBuilder(
            awaiter: self,
            waitLock: waitLock,
            promise: promise,
            trigger: trigger)
    }
}

internal func pollBlock(
    pollInterval: NimbleTimeInterval,
    timeoutInterval: NimbleTimeInterval,
    file: FileString,
    line: UInt,
    fnName: String = #function,
    expression: @escaping () throws -> PollStatus) -> PollResult<Bool> {
        let awaiter = NimbleEnvironment.activeInstance.awaiter
        let result = awaiter.poll(pollInterval) { () throws -> Bool? in
            if case .finished(let result) = try expression() {
                return result
            }
            return nil
        }
            .timeout(timeoutInterval, forcefullyAbortTimeout: timeoutInterval.divided)
            .wait(fnName, file: file, line: line)

        return result
}

#endif // #if !os(WASI)
