import Foundation

struct AsyncMatcherWrapper<T, U where U: MatcherWithFullMessage, U.ValueType == T> : MatcherWithFullMessage {
    let fullMatcher: U
    let timeoutInterval: NSTimeInterval = 1
    let pollInterval: NSTimeInterval = 0.01

    func pollExpression(expression: () -> (Bool, String)) -> (Bool, String) {
        let startDate = NSDate()
        var pass: Bool
        var message: String
        do {
            (pass, message) = expression()
            let runDate = NSDate().addTimeInterval(pollInterval) as NSDate
            NSRunLoop.mainRunLoop().runUntilDate(runDate)
        } while(!pass && NSDate().timeIntervalSinceDate(startDate) < timeoutInterval);
        return (pass, message)
    }

    func matches(actualExpression: Expression<T>) -> (pass: Bool, message: String) {
        let uncachedExpression = actualExpression.withoutCaching()
        return pollExpression { self.fullMatcher.matches(uncachedExpression) }
    }

    func doesNotMatch(actualExpression: Expression<T>) -> (pass: Bool, message: String)  {
        let uncachedExpression = actualExpression.withoutCaching()
        return pollExpression {
            let (success, message) = self.fullMatcher.matches(uncachedExpression)
            return (!success, message)
        }
    }
}

extension Expectation {
    func toEventually<U where U: MatcherWithFullMessage, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.1) {
        to(AsyncMatcherWrapper(fullMatcher: matcher, timeoutInterval: timeout, pollInterval: pollInterval))
    }

    func toEventuallyNot<U where U: MatcherWithFullMessage, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.1) {
        toNot(AsyncMatcherWrapper(fullMatcher: matcher, timeoutInterval: timeout, pollInterval: pollInterval))
    }

    func toEventually<U where U: Matcher, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.1) {
        to(AsyncMatcherWrapper(
            fullMatcher: FullMatcherWrapper(
                matcher: matcher,
                to: "to eventually",
                toNot: "to eventually not"),
            timeoutInterval: timeout,
            pollInterval: pollInterval))
    }

    func toEventuallyNot<U where U: Matcher, U.ValueType == T>(matcher: U, timeout: NSTimeInterval = 1, pollInterval: NSTimeInterval = 0.1) {
        toNot(AsyncMatcherWrapper(
            fullMatcher: FullMatcherWrapper(
                matcher: matcher,
                to: "to eventually",
                toNot: "to eventually not"),
            timeoutInterval: timeout,
            pollInterval: pollInterval))
    }
}
