import Foundation

/// Only classes, protocols, methods, properties, and subscript declarations can be
/// bridges to Objective-C via the @objc keyword. This class encapsulates callback-style
/// asynchronous waiting logic so that it may be called from Objective-C and Swift.
@objc public class NMBWait {
    public class func until(#timeout: NSTimeInterval, action: (() -> Void) -> Void, file: String = __FILE__, line: UInt = __LINE__) -> Void {
        var completed = false
        var token: dispatch_once_t = 0
        let result = pollBlock(pollInterval: 0.01, timeoutInterval: timeout) {
            dispatch_once(&token) {
                dispatch_async(dispatch_get_main_queue()) {
                    action() { completed = true }
                }
            }
            return completed
        }
        if result == PollResult.Failure {
            let pluralize = (timeout == 1 ? "" : "s")
            fail("Waited more than \(timeout) second\(pluralize)", file: file, line: line)
        } else if result == PollResult.Timeout {
            fail("Stall on main thread - too much enqueued on main run loop before waitUntil executes.", file: file, line: line)
        }
    }

    public class func until(action: (() -> Void) -> Void, file: String = __FILE__, line: UInt = __LINE__) -> Void {
        until(timeout: 1, action: action, file: file, line: line)
    }
}

/// Wait asynchronously until the done closure is called.
///
/// This will advance the run loop.
public func waitUntil(#timeout: NSTimeInterval, action: (() -> Void) -> Void, file: String = __FILE__, line: UInt = __LINE__) -> Void {
    NMBWait.until(timeout: timeout, action: action, file: file, line: line)
}

/// Wait asynchronously until the done closure is called.
///
/// This will advance the run loop.
public func waitUntil(action: (() -> Void) -> Void, file: String = __FILE__, line: UInt = __LINE__) -> Void {
    NMBWait.until(action, file: file, line: line)
}