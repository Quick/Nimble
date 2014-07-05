import Foundation

struct Expectation<T> {
    let expression: Expression<T>

    func verify(pass: Bool, _ message: String) {
        CurrentAssertionHandler.assert(pass, message: message, location: expression.location)
    }

    func to<U where U: Matcher, U.ValueType == T>(matcher: U) {
        var msg = FailureMessage()
        let pass = matcher.matches(expression, failureMessage: msg)
        if msg.actualValue == "" {
            msg.actualValue = "<\(stringify(expression.evaluate()))>"
        }
        verify(pass, msg.stringValue())
    }

    func toNot<U where U: Matcher, U.ValueType == T>(matcher: U) {
        var msg = FailureMessage()
        let pass = matcher.doesNotMatch(expression, failureMessage: msg)
        if msg.actualValue == "" {
            msg.actualValue = "<\(stringify(expression.evaluate()))>"
        }
        verify(pass, msg.stringValue())
    }

    func notTo<U where U: Matcher, U.ValueType == T>(matcher: U) {
        toNot(matcher)
    }

    // see FullMatcherWrapper and AsyncMatcherWrapper for extensions
    // see NMBExpectation for Objective-C interface
}

