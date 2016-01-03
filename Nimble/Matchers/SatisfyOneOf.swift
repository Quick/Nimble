import Foundation

public func satisfyOneOf<T,U where U: Matcher, U.ValueType == T>(matchers: U...) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc<T> { actualExpression, failureMessage in
        var fullPostfixMessage = "match one of: "
        var matches = false
        for var i = 0; i < matchers.count && !matches; ++i {
            fullPostfixMessage += "{"
            let matcher = matchers[i]
            matches = try matcher.matches(actualExpression, failureMessage: failureMessage)
            fullPostfixMessage += "\(failureMessage.postfixMessage)}"
            if i < (matchers.count - 1) {
                fullPostfixMessage += ", "
            }
        }
        
        failureMessage.postfixMessage = fullPostfixMessage
        if let actualValue = try actualExpression.evaluate() {
            failureMessage.actualValue = "\(actualValue)"
        }
        
        return matches
    }
}
