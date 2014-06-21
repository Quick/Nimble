import Foundation

struct FullMatcherWrapper<M, T where M: Matcher, M.ValueType == T> : MatcherWithFullMessage {
    let matcher: M
    let to: String
    let toNot: String

    func matches(actualExpression: Expression<T>) -> (pass: Bool, message: String)  {
        let (pass, postfix) = matcher.matches(actualExpression)
        return (pass, "expected <\(actualExpression.evaluate())> \(to) \(postfix)")
    }

    func doesNotMatch(actualExpression: Expression<T>) -> (pass: Bool, message: String)  {
        let (pass, postfix) = matcher.matches(actualExpression)
        return (!pass, "expected <\(actualExpression.evaluate())> \(toNot) \(postfix)")
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
