#if !os(WASI)

import CoreFoundation
import Dispatch
import Foundation
#if canImport(Testing)
@_implementationOnly import Testing
#endif

private let timeoutLeeway = NimbleTimeInterval.milliseconds(1)
private let pollLeeway = NimbleTimeInterval.milliseconds(1)

/// Stores debugging information about callers
private struct WaitingInfo: CustomStringConvertible, Sendable {
    let name: String
    let sourceLocation: SourceLocation

    var description: String {
        return "\(name) at \(sourceLocation)"
    }
}

@TaskLocal private var currentWaitingInfo: WaitingInfo? = nil

private func guaranteeNotNested<T>(
    fnName: String,
    sourceLocation: SourceLocation,
    closure: () -> T
) -> T {
    let info = WaitingInfo(name: fnName, sourceLocation: sourceLocation)
    nimblePrecondition(
        currentWaitingInfo == nil,
        "InvalidNimbleAPIUsage",
        """
        Nested async expectations are not allowed to avoid creating flaky tests.

        The call to
        \t\(info)
        triggered this exception because
        \t\(currentWaitingInfo!)
        is currently managing the main run loop.
        """
    )

    return $currentWaitingInfo.withValue(info) {
        closure()
    }
}

internal enum PollResult<T> {
    /// Incomplete indicates None (aka - this value hasn't been fulfilled yet)
    case incomplete
    /// TimedOut indicates the result reached its defined timeout limit before returning
    case timedOut
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

func synchronousWaitUntil(
    timeout: NimbleTimeInterval,
    fnName: String,
    sourceLocation: SourceLocation,
    closure: @escaping (@escaping () -> Void) throws -> Void
) -> PollResult<Void> {
#if canImport(Testing)
    if Test.current != nil {
        fail("""
The synchronous `waitUntil(...)` is known to not work in Swift Testing's parallel test execution environment.
Please use Swift Testing's `confirmation(...)` APIs to accomplish (nearly) the same thing.
""",
             location: sourceLocation)
    }
#endif

    return guaranteeNotNested(fnName: fnName, sourceLocation: sourceLocation) {
        let runloop = RunLoop.current

        nonisolated(unsafe) var result = PollResult<Void>.timedOut
        let lock = NSLock()

        let doneBlock: () -> Void = {
            let onFinish = {
                lock.lock()
                defer { lock.unlock() }
                if case .completed = result {
                    fail("waitUntil(...) expects its completion closure to be only called once", location: sourceLocation)
                    return
                }
#if canImport(CoreFoundation)
                CFRunLoopStop(runloop.getCFRunLoop())
#else
                RunLoop.main._stop()
#endif
                result = .completed(())
            }
            if Thread.isMainThread {
                onFinish()
            } else {
                DispatchQueue.main.sync { onFinish() }
            }
        }

        let capture = NMBExceptionCapture(
            handler: ({ exception in
                lock.lock()
                defer { lock.unlock() }
                result = .raisedException(exception)
            }),
            finally: ({ })
        )
        capture.tryBlock {
            do {
                try closure(doneBlock)
            } catch {
                lock.lock()
                defer { lock.unlock() }
                result = .errorThrown(error)
            }
        }

        if Thread.isMainThread {
            runloop.run(mode: .default, before: Date(timeIntervalSinceNow: timeout.timeInterval))
        } else {
            DispatchQueue.main.sync {
                _ = runloop.run(mode: .default, before: Date(timeIntervalSinceNow: timeout.timeInterval))
            }
        }

        lock.lock()
        defer { lock.unlock() }
        return result
    }
}

internal func pollBlock(
    pollInterval: NimbleTimeInterval,
    timeoutInterval: NimbleTimeInterval,
    sourceLocation: SourceLocation,
    fnName: String,
    isContinuous: Bool,
    expression: @escaping () throws -> PollStatus
) -> PollResult<Bool> {
    guaranteeNotNested(fnName: fnName, sourceLocation: sourceLocation) {
        if Test.current != nil {
            fail("""
    The synchronous `\(fnName)` is known to not work in Swift Testing's parallel test execution environment.
    Please use the asynchronous `\(fnName)` to accomplish the same thing.
    """,
                 location: sourceLocation)
        }
        let interval = pollInterval > .nanoseconds(0) ? pollInterval : .nanoseconds(1)
        precondition(timeoutInterval > interval)
        let iterations = Int(exactly: (timeoutInterval / pollInterval).rounded(.up)) ?? Int.max

        for i in 0..<iterations {
            do {
                if case .finished(let result) = try expression() {
                    return .completed(result)
                }
            } catch {
                return .errorThrown(error)
            }
            if i == (iterations - 1) {
                break
            }
            RunLoop.main.run(until: Date(timeIntervalSinceNow: pollInterval.timeInterval))
        }
        return .timedOut
    }
}

#endif // #if !os(WASI)
