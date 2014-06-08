import Foundation

struct Expectation<T> {
    let expression: Expression<T>
    let assertion: AssertionHandler = CurrentAssertionHandler
    var location: SourceLocation { return expression.location }

    init(expression: Expression<T>) {
        self.expression = expression
    }

    func verify(pass: Bool, message: String) {
        assertion.assert(pass, message: message, location: location)
    }

    func toEventually<U where U: MatcherWithFullMessage, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, checkInterval: NSTimeInterval = 0.1) {
        let startDate = NSDate()
        var pass: Bool
        var message: String
        do {
            (pass, message) = matcher.matches(expression)
            let runDate = NSDate().addTimeInterval(checkInterval) as NSDate
            NSRunLoop.mainRunLoop().runUntilDate(runDate)
        } while(!pass || startDate.timeIntervalSinceNow > timeout);
        verify(pass, message: message)
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
        let actualValue = expression.evaluate()
        let (pass, messagePostfix) = matcher.matches(expression)
        verify(pass, message: "expected <\(actualValue)> to \(messagePostfix)")
    }

    func toNot<U where U: Matcher, U.ValueType == T>(matcher: U) {
        let actualValue = expression.evaluate()
        let (pass, messagePostfix) = matcher.matches(expression)
        verify(!pass, message: "expected <\(actualValue)> to not \(messagePostfix)")
    }
}
