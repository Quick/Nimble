#if !os(WASI)
import CoreFoundation
import Dispatch
import Foundation
#if canImport(Testing)
@_implementationOnly import Testing
#endif

private let timeoutLeeway = NimbleTimeInterval.milliseconds(1)
private let pollLeeway = NimbleTimeInterval.milliseconds(1)

// Like PollResult, except it doesn't support objective-c exceptions.
// Which is tolerable because Swift Concurrency doesn't support recording objective-c exceptions.
internal enum AsyncPollResult<T> {
    /// Incomplete indicates None (aka - this value hasn't been fulfilled yet)
    case incomplete
    /// TimedOut indicates the result reached its defined timeout limit before returning
    case timedOut
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
        case .completed(let value): return .completed(value)
        case .errorThrown(let error): return .errorThrown(error)
        }
    }
}

final class BlockingTask: Sendable {
    private nonisolated(unsafe) var finished = false
    private nonisolated(unsafe) var continuation: CheckedContinuation<Void, Never>? = nil
    let sourceLocation: SourceLocation
    private let lock = NSLock()

    init(sourceLocation: SourceLocation) {
        self.sourceLocation = sourceLocation
    }

    func run() async {
        if let continuation = lock.withLock({ self.continuation }) {
            continuation.resume()
        }
        await withTaskCancellationHandler {
            await withCheckedContinuation {
                lock.lock()
                defer { lock.unlock() }

                if finished {
                    $0.resume()
                } else {
                    self.continuation = $0
                }
            }
        } onCancel: {
            handleCancellation()
        }

    }

    func complete() {
        lock.lock()
        defer { lock.unlock() }

        if finished {
            fail(
                "waitUntil(...) expects its completion closure to be only called once",
                location: sourceLocation
            )
        } else {
            finished = true
            self.continuation?.resume()
            self.continuation = nil
        }
    }

    func handleCancellation() {
        lock.lock()
        defer { lock.unlock() }

        guard finished == false else {
            return
        }
        continuation?.resume()
        continuation = nil
    }
}

final class ResultTracker<T: Sendable>: Sendable {
    var result: AsyncPollResult<T> {
        lock.lock()
        defer { lock.unlock() }
        return _result
    }

    private nonisolated(unsafe) var _result: AsyncPollResult<T> = .incomplete
    private let lock = NSLock()


    func finish(with result: AsyncPollResult<T>) {
        lock.lock()
        defer {
            lock.unlock()
        }
        guard case .incomplete = _result else {
            return
        }
        self._result = result
    }
}

internal func performBlock(
    timeout: NimbleTimeInterval,
    leeway: NimbleTimeInterval,
    sourceLocation: SourceLocation,
    closure: @escaping @Sendable (@escaping @Sendable () -> Void) async throws -> Void
) async -> AsyncPollResult<Void> {
    precondition(timeout > .seconds(0))

    #if canImport(Testing)
#if swift(>=6.3)
    Issue.record(
        "waitUntil(...) becomes less reliable the more tasks and processes your system is running. " +
        "This makes it unsuitable for use with Swift Testing. Please use Swift Testing's confirmation(...) API instead.",
        severity: .warning,
        sourceLocation: SourceLocation(
            fileID: sourceLocation.fileID,
            filePath: sourceLocation.filePath,
            line: sourceLocation.line,
            column: sourceLocation.column
        )
    )
#endif
    #endif

    return await withTaskGroup(of: Void.self) { taskGroup in
        let blocker = BlockingTask(sourceLocation: sourceLocation)
        let tracker = ResultTracker<Void>()

        taskGroup.addTask {
            await blocker.run()
        }

        taskGroup.addTask {
            do {
                try await closure {
                    blocker.complete()
                    tracker.finish(with: .completed(()))
                }
            } catch {
                tracker.finish(with: .errorThrown(error))
            }
        }

        taskGroup.addTask {
            do {
                try await Task.sleep(nanoseconds: (timeout + leeway).nanoseconds)
                tracker.finish(with: .timedOut)
            } catch {

            }
        }

        var result: AsyncPollResult<Void> = .incomplete

        for await _ in taskGroup {
            result = tracker.result
            if case .incomplete = result {
                continue
            }
            break
        }
        taskGroup.cancelAll()
        return result
    }
}

internal func pollBlock(
    pollInterval: NimbleTimeInterval,
    timeoutInterval: NimbleTimeInterval,
    sourceLocation: SourceLocation,
    expression: @escaping () async throws -> PollStatus
) async -> AsyncPollResult<Bool> {
    precondition(timeoutInterval > pollInterval)
    precondition(pollInterval > .seconds(0))
    let iterations = Int(exactly: (timeoutInterval / pollInterval).rounded(.up)) ?? Int.max

    for iteration in 0..<iterations {
        do {
            if case .finished(let result) = try await expression() {
                return .completed(result)
            }
        } catch {
            return .errorThrown(error)
        }
        if iteration == (iterations - 1) {
            break
        }
        do {
            try await Task.sleep(nanoseconds: pollInterval.nanoseconds)
        } catch {
            return .errorThrown(error)
        }
    }
    return .timedOut
}

#endif // #if !os(WASI)
