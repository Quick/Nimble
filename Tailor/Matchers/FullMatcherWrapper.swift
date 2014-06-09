import Foundation

struct FullMatcherWrapper<M, T where M: Matcher, M.ValueType == T> : MatcherWithFullMessage {
    let matcher: M
    let to: String
    let toNot: String

    func matches(actualExpression: Expression<T>) -> (pass: Bool, message: String)  {
        let (pass, messagePostfix) = matcher.matches(actualExpression)
        return (pass, "expected <\(actualExpression.evaluate())> \(to) \(messagePostfix)")
    }

    func doesNotMatch(actualExpression: Expression<T>) -> (pass: Bool, message: String)  {
        let (pass, messagePostfix) = matcher.matches(actualExpression)
        return (!pass, "expected <\(actualExpression.evaluate())> \(toNot) \(messagePostfix)")
    }
}

extension Expectation {
    func to<U where U: Matcher, U.ValueType == T>(matcher: U) {
        to(FullMatcherWrapper(matcher: matcher, to: "to", toNot: "to not"))
    }

    func toNot<U where U: Matcher, U.ValueType == T>(matcher: U) {
        toNot(FullMatcherWrapper(matcher: matcher, to: "to", toNot: "to not"))
    }
}
