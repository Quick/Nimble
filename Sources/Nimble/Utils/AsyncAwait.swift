#if !os(WASI)

#if canImport(CoreFoundation)
import CoreFoundation
#endif

import Dispatch
import Foundation

private let timeoutLeeway = NimbleTimeInterval.milliseconds(1)
private let pollLeeway = NimbleTimeInterval.milliseconds(1)

// Like PollResult, except it doesn't support objective-c exceptions.
// Which is tolerable because Swift Concurrency doesn't support recording objective-c exceptions.
internal enum AsyncPollResult<T> {
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

    func toPollResult() -> PollResult<T> {
        switch self {
        case .incomplete: return .incomplete
        case .timedOut: return .timedOut
        case .blockedRunLoop: return .blockedRunLoop
        case .completed(let value): return .completed(value)
        case .errorThrown(let error): return .errorThrown(error)
        }
    }
}

// A mechanism to send a single value between 2 tasks.
// Inspired by swift-async-algorithm's AsyncChannel, but massively simplified
// especially given Nimble's usecase.
// AsyncChannel: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/Channels/AsyncChannel.swift
internal actor AsyncPromise<T> {
    private let storage = Storage()

    private final class Storage {
        private var continuations: [UnsafeContinuation<T, Never>] = []
        private var value: T?
        // Yes, this is not the fastest lock, but it's platform independent,
        // which means we don't have to have a Lock protocol and separate Lock
        // implementations for Linux & Darwin (and Windows if we ever add
        // support for that).
        private let lock = NSLock()

        func await() async -> T {
            await withUnsafeContinuation { continuation in
                lock.lock()
                defer { lock.unlock() }
                if let value {
                    continuation.resume(returning: value)
                } else {
                    continuations.append(continuation)
                }
            }
        }

        func send(_ value: T) {
            lock.lock()
            defer { lock.unlock() }
            if self.value != nil { return }
            continuations.forEach { continuation in
                continuation.resume(returning: value)
            }
            continuations = []
            self.value = value
        }
    }

    nonisolated func send(_ value: T) {
        self.storage.send(value)
    }

    var value: T {
        get async {
            await self.storage.await()
        }
    }
}

/// Wait until the timeout period, then checks why the matcher might have timed out
///
/// Why Dispatch?
///
/// Using Dispatch gives us mechanisms for detecting why the matcher timed out.
/// If it timed out because the main thread was blocked, then we want to report that,
/// as that's a performance concern. If it timed out otherwise, then we need to
/// report that.
/// This **could** be done using mechanisms like locks, but instead we use
/// `DispatchSemaphore`. That's because `DispatchSemaphore` is fast and
/// platform independent. However, while `DispatchSemaphore` itself is
/// `Sendable`, the `wait` method is not safe to use in an async context.
/// To get around that, we must ensure that all usages of
/// `DispatchSemaphore.wait` are in synchronous contexts, which
/// we can ensure by dispatching to a `DispatchQueue`. Unlike directly calling
/// a synchronous closure, or using something ilke `MainActor.run`, using
/// a `DispatchQueue` to run synchronous code will actually run it in a
/// synchronous context.
///
///
/// Run Loop Management
///
/// In order to properly interrupt the waiting behavior performed by this factory class,
/// this timer stops the main run loop to tell the waiter code that the result should be
/// checked.
///
/// In addition, stopping the run loop is used to halt code executed on the main run loop.
private func timeout<T>(timeoutQueue: DispatchQueue, timeoutInterval: NimbleTimeInterval, forcefullyAbortTimeout: NimbleTimeInterval) async -> AsyncPollResult<T> {
    do {
        try await Task.sleep(nanoseconds: timeoutInterval.nanoseconds)
    } catch {}

    let promise = AsyncPromise<AsyncPollResult<T>>()

    let timedOutSem = DispatchSemaphore(value: 0)
    let semTimedOutOrBlocked = DispatchSemaphore(value: 0)
    semTimedOutOrBlocked.signal()

    DispatchQueue.main.async {
        if semTimedOutOrBlocked.wait(timeout: .now()) == .success {
            timedOutSem.signal()
            semTimedOutOrBlocked.signal()
            promise.send(.timedOut)
        }
    }

    // potentially interrupt blocking code on run loop to let timeout code run
    timeoutQueue.async {
        let abortTimeout = DispatchTime.now() + timeoutInterval.divided.dispatchTimeInterval
        let didNotTimeOut = timedOutSem.wait(timeout: abortTimeout) != .success
        let timeoutWasNotTriggered = semTimedOutOrBlocked.wait(timeout: .now()) == .success
        if didNotTimeOut && timeoutWasNotTriggered {
            promise.send(.blockedRunLoop)
        } else {
            promise.send(.timedOut)
        }
    }

    return await promise.value
}

private func poll(_ pollInterval: NimbleTimeInterval, expression: @escaping () async throws -> Bool) async -> AsyncPollResult<Bool> {
    for try await _ in AsyncTimerSequence(interval: pollInterval) {
        do {
            if try await expression() {
                return .completed(true)
            }
        } catch {
            return .errorThrown(error)
        }
    }
    return .completed(false)
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
/// The returned AsyncPollResult will NEVER be .incomplete.
private func runPoller(
    timeoutInterval: NimbleTimeInterval,
    pollInterval: NimbleTimeInterval,
    awaiter: Awaiter,
    fnName: String = #function, file: FileString = #file, line: UInt = #line,
    expression: @escaping () async throws -> Bool
) async -> AsyncPollResult<Bool> {
    awaiter.waitLock.acquireWaitingLock(
        fnName,
        file: file,
        line: line)

    defer {
        awaiter.waitLock.releaseWaitingLock()
    }
    let timeoutQueue = awaiter.timeoutQueue
    return await withTaskGroup(of: AsyncPollResult<Bool>.self) { taskGroup in
        taskGroup.addTask {
            await timeout(
                timeoutQueue: timeoutQueue,
                timeoutInterval: timeoutInterval,
                forcefullyAbortTimeout: timeoutInterval.divided
            )
        }

        taskGroup.addTask {
            await poll(pollInterval, expression: expression)
        }

        defer {
            taskGroup.cancelAll()
        }

        return await taskGroup.next() ?? .timedOut
    }
}

private final class Box<T: Sendable>: @unchecked Sendable {
    private var _value: T
    var value: T {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    private let lock = NSLock()

    init(value: T) {
        _value = value
    }

    func operate(_ closure: @Sendable (T) -> T) {
        lock.lock()
        defer { lock.unlock() }
        _value = closure(_value)
    }
}

// swiftlint:disable:next function_parameter_count
private func runAwaitTrigger<T>(
    awaiter: Awaiter,
    timeoutInterval: NimbleTimeInterval,
    leeway: NimbleTimeInterval,
    file: FileString, line: UInt,
    _ closure: @escaping (@escaping (T) -> Void) async throws -> Void
) async -> AsyncPollResult<T> {
    let timeoutQueue = awaiter.timeoutQueue
    let completionCount = Box(value: 0)
    return await withTaskGroup(of: AsyncPollResult<T>.self) { taskGroup in
        let promise = AsyncPromise<T?>()

        taskGroup.addTask {
            defer {
                promise.send(nil)
            }
            return await timeout(
                timeoutQueue: timeoutQueue,
                timeoutInterval: timeoutInterval,
                forcefullyAbortTimeout: leeway
            )
        }

        taskGroup.addTask {
            do {
                try await closure { result in
                    completionCount.operate { $0 + 1 }
                    if completionCount.value < 2 {
                        promise.send(result)
                    } else {
                        fail("waitUntil(..) expects its completion closure to be only called once",
                             file: file, line: line)
                    }
                }
                if let value = await promise.value {
                    return .completed(value)
                } else {
                    return .timedOut
                }
            } catch {
                return .errorThrown(error)
            }
        }

        defer {
            taskGroup.cancelAll()
        }

        return await taskGroup.next() ?? .timedOut
    }
}

internal func performBlock<T>(
    timeoutInterval: NimbleTimeInterval,
    leeway: NimbleTimeInterval,
    file: FileString, line: UInt,
    _ closure: @escaping (@escaping (T) -> Void) async throws -> Void
) async -> AsyncPollResult<T> {
    await runAwaitTrigger(
        awaiter: NimbleEnvironment.activeInstance.awaiter,
        timeoutInterval: timeoutInterval,
        leeway: leeway,
        file: file, line: line, closure)
}

internal func pollBlock(
    pollInterval: NimbleTimeInterval,
    timeoutInterval: NimbleTimeInterval,
    file: FileString,
    line: UInt,
    fnName: String = #function,
    expression: @escaping () async throws -> Bool) async -> AsyncPollResult<Bool> {
        await runPoller(
            timeoutInterval: timeoutInterval,
            pollInterval: pollInterval,
            awaiter: NimbleEnvironment.activeInstance.awaiter,
            expression: expression
        )
    }

#endif // #if !os(WASI)
