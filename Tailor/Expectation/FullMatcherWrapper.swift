import Foundation

struct FullMatcherWrapper<M, T where M: BasicMatcher, M.ValueType == T> : Matcher {
    let matcher: M
    let to: String
    let toNot: String

    func matches(actualExpression: Expression<T>) -> (Bool, String)  {
        let (pass, postfix) = matcher.matches(actualExpression)
        return (pass, "expected <\(actualExpression.evaluate())> \(to) \(postfix)")
    }

    func doesNotMatch(actualExpression: Expression<T>) -> (Bool, String)  {
        let (pass, postfix) = matcher.matches(actualExpression)
        return (!pass, "expected <\(actualExpression.evaluate())> \(toNot) \(postfix)")
    }
}

extension Expectation {
    func to<U where U: BasicMatcher, U.ValueType == T>(matcher: U) {
        to(FullMatcherWrapper(matcher: matcher, to: "to", toNot: "to not"))
    }

    func toNot<U where U: BasicMatcher, U.ValueType == T>(matcher: U) {
        toNot(FullMatcherWrapper(matcher: matcher, to: "to", toNot: "to not"))
    }
}
