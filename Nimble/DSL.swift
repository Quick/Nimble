import Foundation

/// Make an expectation on a given actual value. The value given is lazily evaluated.
public func expect<T>(expression: @autoclosure () -> T?, file: String = __FILE__, line: UInt = __LINE__) -> Expectation<T> {
    return Expectation(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line)))
}

/// Make an expectation on a given actual value. The closure is lazily invoked.
public func expect<T>(file: String = __FILE__, line: UInt = __LINE__, expression: () -> T?) -> Expectation<T> {
    return Expectation(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line)))
}

/// Wait asynchronously until the done closure is called.
///
/// This will advance the run loop.
public func waitUntil(#timeout: NSTimeInterval, action: (() -> Void) -> Void, file: String = __FILE__, line: UInt = __LINE__) -> Void {
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

/// Wait asynchronously until the done closure is called.
///
/// This will advance the run loop.
public func waitUntil(action: (() -> Void) -> Void, file: String = __FILE__, line: UInt = __LINE__) -> Void {
    waitUntil(timeout: 1, action, file: file, line: line)
}

/// Always fails the test with a message and a specified location.
public func fail(message: String, #location: SourceLocation) {
    CurrentAssertionHandler.assert(false, message: message, location: location)
}

/// Always fails the test with a message.
public func fail(message: String, file: String = __FILE__, line: UInt = __LINE__) {
    fail(message, location: SourceLocation(file: file, line: line))
}

/// Always fails the test.
public func fail(file: String = __FILE__, line: UInt = __LINE__) {
    fail("fail() always fails")
}