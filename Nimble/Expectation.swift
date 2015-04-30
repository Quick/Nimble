import Foundation

func expectTo<T, U where U: Matcher, U.ValueType == T>(expression: Expression<T>, matcher: U, to: String) -> (Bool, FailureMessage) {
    var msg = FailureMessage()
    msg.to = to
    let pass = matcher.matches(expression, failureMessage: msg)
    if msg.actualValue == "" {
        msg.actualValue = "<\(stringify(expression.evaluate()))>"
    }
    return (pass, msg)
}

func expectToNot<T, U where U: Matcher, U.ValueType == T>(expression: Expression<T>, matcher: U, toNot: String) -> (Bool, FailureMessage) {
    var msg = FailureMessage()
    msg.to = toNot
    let pass = matcher.doesNotMatch(expression, failureMessage: msg)
    if msg.actualValue == "" {
        msg.actualValue = "<\(stringify(expression.evaluate()))>"
    }
    return (pass, msg)
}

public struct Expectation<T> {
    let expression: Expression<T>

    public func verify(pass: Bool, _ message: String) {
        NimbleAssertionHandler.assert(pass, message: message, location: expression.location)
    }

    public func to<U where U: Matcher, U.ValueType == T>(matcher: U) {
        let (pass, msg) = expectTo(expression, matcher, "to")
        verify(pass, msg.stringValue())
    }

    public func toNot<U where U: Matcher, U.ValueType == T>(matcher: U) {
        let (pass, msg) = expectToNot(expression, matcher, "to not")
        verify(pass, msg.stringValue())
    }

    public func notTo<U where U: Matcher, U.ValueType == T>(matcher: U) {
        toNot(matcher)
    }

    // see:
    // - AsyncMatcherWrapper for extension
    // - NMBExpectation for Objective-C interface
}
