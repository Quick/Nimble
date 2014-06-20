import Foundation

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(expression: @auto_closure () -> T, file: String = __FILE__, line: Int = __LINE__) -> Expectation<T> {
    return Expectation(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line)))
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(file: String = __FILE__, line: Int = __LINE__, expression: () -> T) -> Expectation<T> {
    return Expectation(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line)))
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func waitUntil(#timeout: NSTimeInterval, action: (() -> Void) -> Void, file: String = __FILE__, line: Int = __LINE__) -> Void {
    let semaphore = dispatch_semaphore_create(0)
    let queue = dispatch_queue_create("net.jeffhui.tailor.matchers", DISPATCH_QUEUE_SERIAL)
    var passed = false
    dispatch_async(queue) {
        action() {
            passed = true
            dispatch_semaphore_signal(semaphore)
        }
    }
    let stopTime = dispatch_time(DISPATCH_TIME_NOW, Int64(round(timeout * NSTimeInterval(NSEC_PER_SEC))))
    dispatch_semaphore_wait(semaphore, stopTime)
    if !passed {
        let pluralize = timeout == 1 ? "" : "s"
        fail("Waited more than \(timeout) second\(pluralize)", file: file, line: line)
    }
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func waitUntil(action: (() -> Void) -> Void, file: String = __FILE__, line: Int = __LINE__) -> Void {
    waitUntil(timeout: 1, action, file: file, line: line)
}

func must(assertion: Bool, message: String, #location: SourceLocation) {
    CurrentAssertionHandler.assert(false, message: message, location: location)
}

func must(assertion: Bool, message: String, file: String = __FILE__, line: Int = __LINE__) {
    must(assertion, message, location: SourceLocation(file: file, line: line))
}

func fail(message: String, #location: SourceLocation) {
    must(false, message, location: location)
}

func fail(message: String, file: String = __FILE__, line: Int = __LINE__) {
    fail(message, location: SourceLocation(file: file, line: line))
}

func fail(file: String = __FILE__, line: Int = __LINE__) {
    fail("Failed")
}