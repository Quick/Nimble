import Foundation

struct _BeLessThan<T: Comparable>: Matcher {
    let expectedValue: T

    func matches(actualExpression: () -> T) -> (pass: Bool, messagePostfix: String)  {
        let actualValue = actualExpression()
        return (actualValue < expectedValue, "be less than <\(expectedValue)>")
    }
}

func beLessThan<T>(expectedValue: T) -> PartialMatcher<T, _BeLessThan<T>> {
    return PartialMatcher(matcher: _BeLessThan(expectedValue: expectedValue))
}

func <<T: Comparable>(lhs: _Expectation<T>, rhs: T) -> Bool {
    lhs.to(beLessThan(rhs))
    return true
}
