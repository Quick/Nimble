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
        fileID: String = #fileID,
        file: FileString = #filePath,
        line: UInt = #line,
        column: UInt = #column,
        action: @escaping (@escaping () -> Void) -> Void) {
            // Convert TimeInterval to NimbleTimeInterval
            until(timeout: timeout.nimbleInterval, file: file, line: line, action: action)
    }
#endif

    public class func until(
        timeout: NimbleTimeInterval,
        fileID: String = #fileID,
        file: FileString = #filePath,
        line: UInt = #line,
        column: UInt = #column,
        action: @escaping (@escaping () -> Void) -> Void) {
            return throwableUntil(timeout: timeout, file: file, line: line) { done in
                action(done)
            }
    }

    // Using a throwable closure makes this method not objc compatible.
    public class func throwableUntil(
        timeout: NimbleTimeInterval,
        fileID: String = #fileID,
        file: FileString = #filePath,
        line: UInt = #line,
        column: UInt = #column,
        action: @escaping (@escaping () -> Void) throws -> Void) {
            let awaiter = NimbleEnvironment.activeInstance.awaiter
            let leeway = timeout.divided
            let result = awaiter.performBlock(file: file, line: line) { (done: @escaping (ErrorResult) -> Void) throws -> Void in
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
            }.timeout(timeout, forcefullyAbortTimeout: leeway).wait(
                "waitUntil(...)",
                sourceLocation: SourceLocation(fileID: fileID, filePath: file, line: line, column: column)
            )

            switch result {
            case .incomplete: internalError("Reached .incomplete state for waitUntil(...).")
            case .blockedRunLoop:
                fail(blockedRunLoopErrorMessageFor("-waitUntil()", leeway: leeway),
                     fileID: fileID, file: file, line: line, column: column)
            case .timedOut:
                fail("Waited more than \(timeout.description)",
                     fileID: fileID, file: file, line: line, column: column)
            case let .raisedException(exception):
                fail("Unexpected exception raised: \(exception)",
                     fileID: fileID, file: file, line: line, column: column
                )
            case let .errorThrown(error):
                fail("Unexpected error thrown: \(error)",
                     fileID: fileID, file: file, line: line, column: column
                )
            case .completed(.exception(let exception)):
                fail("Unexpected exception raised: \(exception)",
                     fileID: fileID, file: file, line: line, column: column
                )
            case .completed(.error(let error)):
                fail("Unexpected error thrown: \(error)",
                     fileID: fileID, file: file, line: line, column: column
                )
            case .completed(.none): // success
                break
            }
    }

#if canImport(Darwin)
    @objc(untilFileID:file:line:column:action:)
    public class func until(
        _ fileID: String = #fileID,
        file: FileString = #filePath,
        line: UInt = #line,
        column: UInt = #column,
        action: @escaping (@escaping () -> Void) -> Void) {
        until(timeout: .seconds(1), fileID: fileID, file: file, line: line, column: column, action: action)
    }
#else
    public class func until(
        _ fileID: String = #fileID,
        file: FileString = #filePath,
        line: UInt = #line,
        column: UInt = #column,
        action: @escaping (@escaping () -> Void) -> Void) {
        until(timeout: .seconds(1), fileID: fileID, file: file, line: line, column: column, action: action)
    }
#endif
}

internal func blockedRunLoopErrorMessageFor(_ fnName: String, leeway: NimbleTimeInterval) -> String {
    // swiftlint:disable:next line_length
    return "\(fnName) timed out but was unable to run the timeout handler because the main thread is unresponsive (\(leeway.description) is allow after the wait times out). Conditions that may cause this include processing blocking IO on the main thread, calls to sleep(), deadlocks, and synchronous IPC. Nimble forcefully stopped run loop which may cause future failures in test run."
}

/// Wait asynchronously until the done closure is called or the timeout has been reached.
///
/// @discussion
/// Call the done() closure to indicate the waiting has completed.
/// 
/// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
/// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
@available(*, noasync, message: "the sync variant of `waitUntil` does not work in async contexts. Use the async variant as a drop-in replacement")
public func waitUntil(timeout: NimbleTimeInterval = PollingDefaults.timeout, fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, action: @escaping (@escaping () -> Void) -> Void) {
    NMBWait.until(timeout: timeout, fileID: fileID, file: file, line: line, column: column, action: action)
}

#endif // #if !os(WASI)
