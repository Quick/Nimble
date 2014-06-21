import Foundation

struct _BeLessThanMatcher<T: Comparable>: Matcher {
    let expectedValue: T

    func matches(actualExpression: Expression<T>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (actualValue < expectedValue, "be less than <\(expectedValue)>")
    }
}

func beLessThan<T>(expectedValue: T) -> _BeLessThanMatcher<T> {
    return _BeLessThanMatcher(expectedValue: expectedValue)
}

func <<T: Comparable>(lhs: Expectation<T>, rhs: T) -> Bool {
    lhs.to(beLessThan(rhs))
    return true
}
