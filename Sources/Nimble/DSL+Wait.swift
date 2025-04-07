#if !os(WASI)

import Dispatch
import Foundation

private enum ErrorResult {
    case exception(NSException)
    case error(Error)
    case none
}

/// Only classes, protocols, methods, properties, and subscript declarations can be
/// bridges to Objective-C via the @objc keyword. This class encapsulates callback-style
/// asynchronous waiting logic so that it may be called from Objective-C and Swift.
public class NMBWait: NSObject {
// About these kind of lines, `@objc` attributes are only required for Objective-C
// support, so that should be conditional on Darwin platforms.
#if canImport(Darwin)
    @objc
    public class func until(
        timeout: TimeInterval,
        location: SourceLocation = SourceLocation(),
        action: @escaping @Sendable (@escaping @Sendable () -> Void) -> Void) {
            // Convert TimeInterval to NimbleTimeInterval
            until(timeout: timeout.nimbleInterval, location: location, action: action)
    }
#endif

    public class func until(
        timeout: NimbleTimeInterval,
        location: SourceLocation = SourceLocation(),
        action: @escaping @Sendable (@escaping @Sendable () -> Void) -> Void) {
            return throwableUntil(timeout: timeout, location: location) { done in
                action(done)
            }
    }

    // Using a throwable closure makes this method not objc compatible.
    public class func throwableUntil(
        timeout: NimbleTimeInterval,
        location: SourceLocation = SourceLocation(),
        action: @escaping @Sendable (@escaping @Sendable () -> Void) throws -> Void) {
            let awaiter = NimbleEnvironment.activeInstance.awaiter
            let leeway = timeout.divided
            let result = awaiter.performBlock(location: location) { (done: @escaping @Sendable (ErrorResult) -> Void) throws -> Void in
                DispatchQueue.main.async {
                    let capture = NMBExceptionCapture(
                        handler: ({ exception in
                            done(.exception(exception))
                        }),
                        finally: ({ })
                    )
                    capture.tryBlock {
                        do {
                            try action {
                                done(.none)
                            }
                        } catch let e {
                            done(.error(e))
                        }
                    }
                }
            }
                .timeout(timeout, forcefullyAbortTimeout: leeway)
                .wait(
                    "waitUntil(...)",
                    sourceLocation: location
                )

            switch result {
            case .incomplete: internalError("Reached .incomplete state for waitUntil(...).")
            case .blockedRunLoop:
                fail(blockedRunLoopErrorMessageFor("-waitUntil()", leeway: leeway),
                     location: location)
            case .timedOut:
                fail("Waited more than \(timeout.description)",
                     location: location)
            case let .raisedException(exception):
                fail("Unexpected exception raised: \(exception)",
                     location: location
                )
            case let .errorThrown(error):
                fail("Unexpected error thrown: \(error)",
                     location: location
                )
            case .completed(.exception(let exception)):
                fail("Unexpected exception raised: \(exception)",
                     location: location
                )
            case .completed(.error(let error)):
                fail("Unexpected error thrown: \(error)",
                     location: location
                )
            case .completed(.none): // success
                break
            }
    }

#if canImport(Darwin)
    @objc(untilLocation:action:)
    public class func until(
        _ location: SourceLocation = SourceLocation(),
        action: @escaping @Sendable (@escaping @Sendable () -> Void) -> Void) {
            until(timeout: .seconds(1), location: location, action: action)
    }
#else
    public class func until(
        _ location: SourceLocation = SourceLocation(),
        action: @escaping (@escaping () -> Void) -> Void) {
            until(timeout: .seconds(1), location: location, action: action)
    }
#endif
}

internal func blockedRunLoopErrorMessageFor(_ fnName: String, leeway: NimbleTimeInterval) -> String {
    // swiftlint:disable:next line_length
    return "\(fnName) timed out but was unable to run the timeout handler because the main thread is unresponsive. (\(leeway.description) is allowed after the wait times out) Conditions that may cause this include processing blocking IO on the main thread, calls to sleep(), deadlocks, and synchronous IPC. Nimble forcefully stopped the run loop which may cause future failures in test runs."
}

/// Wait asynchronously until the done closure is called or the timeout has been reached.
///
/// @discussion
/// Call the done() closure to indicate the waiting has completed.
/// 
/// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
/// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
@available(*, noasync, message: "the sync variant of `waitUntil` does not work in async contexts. Use the async variant as a drop-in replacement")
public func waitUntil(
    timeout: NimbleTimeInterval = PollingDefaults.timeout,
    location: SourceLocation = SourceLocation(),
    action: @escaping @Sendable (@escaping @Sendable () -> Void) -> Void
) {
    NMBWait.until(timeout: timeout, location: location, action: action)
}

#endif // #if !os(WASI)
