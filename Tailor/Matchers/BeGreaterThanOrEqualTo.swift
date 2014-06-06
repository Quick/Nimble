import Foundation

struct _BeGreaterThanOrEqual<T: Comparable>: Matcher {
    let expectedValue: T

    func matches(actualExpression: () -> T) -> (pass: Bool, messagePostfix: String)  {
        let actualValue = actualExpression()
        return (actualValue >= expectedValue, "be greater than or equal to <\(expectedValue)>")
    }
}

func beGreaterThanOrEqualTo<T: Comparable>(expectedValue: T) -> PartialMatcher<T, _BeGreaterThanOrEqual<T>> {
    return PartialMatcher(matcher: _BeGreaterThanOrEqual(expectedValue: expectedValue))
}

func >=<T: Comparable>(lhs: _Expectation<T>, rhs: T) -> Bool {
    lhs.to(beGreaterThanOrEqualTo(rhs))
    return true
}