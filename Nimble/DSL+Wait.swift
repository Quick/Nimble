import Foundation

/// Only classes, protocols, methods, properties, and subscript declarations can be
/// bridges to Objective-C via the @objc keyword. This class encapsulates callback-style
/// asynchronous waiting logic so that it may be called from Objective-C and Swift.
internal class NMBWait: NSObject {
    internal class func until(
        timeout timeout: NSTimeInterval,
        file: String = __FILE__,
        line: UInt = __LINE__,
        action: (() -> Void) -> Void) -> Void {
            return throwableUntil(timeout: timeout, file: file, line: line) { (done: () -> Void) throws -> Void in
                action() { done() }
            }
    }

    internal class func throwableUntil(
        timeout timeout: NSTimeInterval,
        file: String = __FILE__,
        line: UInt = __LINE__,
        action: (() -> Void) throws -> Void) -> Void {
            let result = Awaiter().performBlock { (done: (Bool) -> Void) throws -> Void in
                try action() {
                    done(true)
                }
            }.enqueueTimeout(timeout).wait("waitUntil(...)", file: file, line: line)

            switch result {
            case .Incomplete: fatalError("Bad implementation: Should never reach .Incomplete state")
            case .BlockedRunLoop:
                fail("Stall on main thread - too much enqueued on main run loop before waitUntil executes.", file: file, line: line)
            case .TimedOut:
                let pluralize = (timeout == 1 ? "" : "s")
                fail("Waited more than \(timeout) second\(pluralize)", file: file, line: line)
            case let .RaisedException(exception):
                fail("Unexpected exception raised: \(exception)")
            case let .ErrorThrown(error):
                fail("Unexpected error thrown: \(error)")
            case .Completed(_): // success
                break
            }
    }

    @objc(untilFile:line:action:)
    internal class func until(file: String = __FILE__, line: UInt = __LINE__, action: (() -> Void) -> Void) -> Void {
        until(timeout: 1, file: file, line: line, action: action)
    }
}

/// Wait asynchronously until the done closure is called or the timeout has been reached.
///
/// @discussion
/// Call the done() closure to indicate the waiting has completed.
/// 
/// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
/// is executing. Any attempts to touch the run loop may calls non-deterministic behavior.
public func waitUntil(timeout timeout: NSTimeInterval = 1, file: String = __FILE__, line: UInt = __LINE__, action: (() -> Void) -> Void) -> Void {
    NMBWait.until(timeout: timeout, file: file, line: line, action: action)
}