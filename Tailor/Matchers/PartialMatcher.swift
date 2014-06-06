import Foundation

struct PartialMatcher<T, M where M: Matcher, M.ValueType == T>: MatcherWithFullMessage {
    let matcher: M

    func matches(actualExpression: () -> T) -> (pass: Bool, message: String)  {
        let actualValue = actualExpression()
        let (pass, messagePostfix) = matcher.matches(actualExpression)
        return (pass, "expected <\(actualValue)> to \(messagePostfix)")
    }

    func doesNotMatch(actualExpression: () -> T) -> (pass: Bool, message: String)  {
        let actualValue = actualExpression()
        let (pass, messagePostfix) = matcher.matches(actualExpression)
        return (!pass, "expected <\(actualValue)> to not \(messagePostfix)")
    }
}
