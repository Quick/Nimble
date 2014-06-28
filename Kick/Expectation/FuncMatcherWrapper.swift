import Foundation

struct FuncMatcherWrapper<T> : BasicMatcher {
    let matcher: (Expression<T>, FailureMessage) -> Bool

    func matches(actualExpression: Expression<T>, failureMessage: FailureMessage) -> Bool {
        return matcher(actualExpression, failureMessage)
    }
}

func MatcherFunc<T>(fn: (Expression<T>, failureMessage: FailureMessage) -> Bool) -> FuncMatcherWrapper<T> {
    return FuncMatcherWrapper(matcher: fn)
}
