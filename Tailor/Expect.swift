import Foundation

// Memoizes the given closure, only calling the passed
// closure once; even if repeat calls to the returned closure
func _memoizedClosure<T>(closure: () -> T) -> () -> T {
    var cache: T?
    return ({
        if (!cache) {
            cache = closure()
        }
        return cache!
    })
}

// Protected. Use one of the helper functions to create this instead.
struct _Expectation<T> {
    let file: String
    let line: Int
    let expression: () -> T
    let assertion: AssertionRecorder = _assertionRecorder!

    init(closure: () -> T, file: String, line: Int) {
        self.expression = _memoizedClosure(closure)
        self.file = file
        self.line = line
    }

    func to<U where U: MatcherWithFullMessage, U.ValueType == T>(matcher: U) {
        let (pass, message) = matcher.matches(expression)
        assertion(assertion: pass, message: message, file: file, line: line)
    }

    func toNot<U where U: MatcherWithFullMessage, U.ValueType == T>(matcher: U) {
        let (pass, message) = matcher.doesNotMatch(expression)
        assertion(assertion: pass, message: message, file: file, line: line)
    }

    // to have more useful error messages
    func to(matcher: Matcher) {
        assertion(assertion: false, message: "Matcher doesn't conform to MatcherWithFullMessage", file: file, line: line)
    }
    func toNot(matcher: Matcher) {
        to(matcher)
    }
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(expression: @auto_closure () -> T, file: String = __FILE__, line: Int = __LINE__) -> _Expectation<T> {
    return _Expectation(closure: expression, file: file, line: line)
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(expression: @auto_closure () -> Void, file: String = __FILE__, line: Int = __LINE__) -> _Expectation<Bool> {
    return _Expectation(closure: ({ expression(); return false }), file: file, line: line)
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(file: String = __FILE__, line: Int = __LINE__, expression: () -> T) -> _Expectation<T> {
    return _Expectation(closure: expression, file: file, line: line)
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(file: String = __FILE__, line: Int = __LINE__, expression: () -> Void) -> _Expectation<Bool> {
    return _Expectation(closure: ({ expression(); return false }), file: file, line: line)
}
