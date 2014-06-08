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

struct Expression<T> {
    let expression: () -> T
    let memoizedExpression: () -> T

    init(closure: () -> T) {
        self.expression = closure
        self.memoizedExpression = _memoizedClosure(closure)
    }

    func evaluateIfNeeded() -> T {
        return self.memoizedExpression()
    }

    func evaluate() -> T {
        return self.expression()
    }
}

// Protected. Use one of the helper functions to create this instead.
struct Expectation<T> {
    let file: String
    let line: Int
    let expression: Expression<T>
    let assertion: AssertionHandler = CurrentAssertionHandler

    init(closure: () -> T, file: String, line: Int) {
        self.expression = Expression(closure: closure)
        self.file = file
        self.line = line
    }

    func verify(pass: Bool, message: String) {
        assertion.assert(pass, message: message, file: file, line: line)
    }

    func to<U where U: MatcherWithFullMessage, U.ValueType == T>(matcher: U) {
        let (pass, message) = matcher.matches(expression)
        verify(pass, message: message)
    }

    func toNot<U where U: MatcherWithFullMessage, U.ValueType == T>(matcher: U) {
        let (pass, message) = matcher.doesNotMatch(expression)
        verify(pass, message: message)
    }

    func to<U where U: Matcher, U.ValueType == T>(matcher: U) {
        let actualValue = expression.evaluateIfNeeded()
        let (pass, messagePostfix) = matcher.matches(expression)
        verify(pass, message: "expected <\(actualValue)> to \(messagePostfix)")
    }

    func toNot<U where U: Matcher, U.ValueType == T>(matcher: U) {
        let actualValue = expression.evaluateIfNeeded()
        let (pass, messagePostfix) = matcher.matches(expression)
        verify(!pass, message: "expected <\(actualValue)> to not \(messagePostfix)")
    }
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(expression: @auto_closure () -> T, file: String = __FILE__, line: Int = __LINE__) -> Expectation<T> {
    return Expectation(closure: expression, file: file, line: line)
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(expression: @auto_closure () -> Void, file: String = __FILE__, line: Int = __LINE__) -> Expectation<Bool> {
    return Expectation(closure: ({ expression(); return false }), file: file, line: line)
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(file: String = __FILE__, line: Int = __LINE__, expression: () -> T) -> Expectation<T> {
    return Expectation(closure: expression, file: file, line: line)
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(file: String = __FILE__, line: Int = __LINE__, expression: () -> Void) -> Expectation<Bool> {
    return Expectation(closure: ({ expression(); return false }), file: file, line: line)
}

func fail(message: String = "exampled failed", file: String = __FILE__, line: Int = __LINE__) {
    CurrentAssertionHandler.assert(false, message: message, file: file, line: line)
}

