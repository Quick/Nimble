import Foundation

struct _BeLessThanOrEqual<T: Comparable>: Matcher {
    let expectedValue: T

    func matches(actualExpression: () -> T) -> (pass: Bool, messagePostfix: String)  {
        let actualValue = actualExpression()
        return (actualValue <= expectedValue, "be less than or equal to <\(expectedValue)>")
    }
}

func beLessThanOrEqualTo<T: Comparable>(expectedValue: T) -> PartialMatcher<T, _BeLessThanOrEqual<T>> {
    return PartialMatcher(matcher: _BeLessThanOrEqual(expectedValue: expectedValue))
}

func <=<T: Comparable>(lhs: _Expectation<T>, rhs: T) -> Bool {
    lhs.to(beLessThanOrEqualTo(rhs))
    return true
}