import Foundation

func expression<T, U where U: Matcher, U.ValueType == T>(expression: Expression<T>, matches: Bool, matcher: U, to: String, description: String?) -> (Bool, FailureMessage) {
    let msg = FailureMessage()
    msg.userDescription = description
    msg.to = matches ? to : "\(to) not"
    do {
        let match = matches ? matcher.matches : matcher.doesNotMatch
        let pass = try match(expression, failureMessage: msg)
        if msg.actualValue == "" {
            msg.actualValue = "<\(stringify(try expression.evaluate()))>"
        }
        return (pass, msg)
    } catch let error {
        msg.actualValue = "an unexpected error thrown: <\(error)>"
        return (false, msg)
    }
}

public struct Expectation<T>: _ExpectationType {
    public typealias Expected = T

    let expression: Expression<T>

    var matches = true

    init(expression: Expression<T>) {
        self.expression = expression
    }

    public var to: Expectation<T> {
        return self
    }

    public var not: Expectation<T> {
        var expectation = self
        expectation.matches = !expectation.matches
        return expectation
    }

    public func verify(pass: Bool, _ message: FailureMessage) {
        let handler = NimbleEnvironment.activeInstance.assertionHandler
        handler.assert(pass, message: message, location: expression.location)
    }

    /// Tests the actual value using a matcher to match.
    public func to<U where U: Matcher, U.ValueType == T>(matcher: U, description: String? = nil) {
        let (pass, msg) = Nimble.expression(expression, matches: matches, matcher: matcher, to: "to", description: description)
        verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    public func toNot<U where U: Matcher, U.ValueType == T>(matcher: U, description: String? = nil) {
        not.to(matcher, description: description)
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    public func notTo<U where U: Matcher, U.ValueType == T>(matcher: U, description: String? = nil) {
        toNot(matcher, description: description)
    }

    // see:
    // - AsyncMatcherWrapper for extension
    // - NMBExpectation for Objective-C interface
}

public protocol _ExpectationType {
    typealias Expected
}

extension _ExpectationType {
    var expectation: Expectation<Expected> {
        return self as! Expectation<Expected>
    }
}
