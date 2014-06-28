import Foundation

struct AsyncMatcherWrapper<T, U where U: Matcher, U.ValueType == T> : Matcher {
    let fullMatcher: U
    let timeoutInterval: NSTimeInterval = 1
    let pollInterval: NSTimeInterval = 0.01

    func pollExpression(expression: () -> Bool) -> Bool {
        let startDate = NSDate()
        var pass: Bool
        do {
            pass = expression()
            let runDate = NSDate().addTimeInterval(pollInterval) as NSDate
            NSRunLoop.mainRunLoop().runUntilDate(runDate)
        } while(!pass && NSDate().timeIntervalSinceDate(startDate) < timeoutInterval);
        return pass
    }

    func matches(actualExpression: Expression<T>, failureMessage: FailureMessage) -> Bool {
        let uncachedExpression = actualExpression.withoutCaching()
        return pollExpression {
            self.fullMatcher.matches(uncachedExpression, failureMessage: failureMessage)
        }
    }

    func doesNotMatch(actualExpression: Expression<T>, failureMessage: FailureMessage) -> Bool  {
        let uncachedExpression = actualExpression.withoutCaching()
        return pollExpression {
            self.fullMatcher.doesNotMatch(uncachedExpression, failureMessage: failureMessage)
        }
    }
}

extension Expectation {
    func toEventually<U where U: Matcher, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.1) {
        to(AsyncMatcherWrapper(fullMatcher: matcher, timeoutInterval: timeout, pollInterval: pollInterval))
    }

    func toEventuallyNot<U where U: Matcher, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.1) {
        toNot(AsyncMatcherWrapper(fullMatcher: matcher, timeoutInterval: timeout, pollInterval: pollInterval))
    }

    func toEventually<U where U: BasicMatcher, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.1) {
        to(AsyncMatcherWrapper(
            fullMatcher: FullMatcherWrapper(
                matcher: matcher,
                to: "to eventually",
                toNot: "to eventually not"),
            timeoutInterval: timeout,
            pollInterval: pollInterval))
    }

    func toEventuallyNot<U where U: BasicMatcher, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.1) {
        toNot(AsyncMatcherWrapper(
            fullMatcher: FullMatcherWrapper(
                matcher: matcher,
                to: "to eventually",
                toNot: "to eventually not"),
            timeoutInterval: timeout,
            pollInterval: pollInterval))
    }
}
