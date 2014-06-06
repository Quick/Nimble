import Foundation

struct _BeGreaterThan<T: Comparable>: Matcher {
    let expectedValue: T

    func matches(actualExpression: () -> T) -> (pass: Bool, messagePostfix: String)  {
        let actualValue = actualExpression()
        return (actualValue > expectedValue, "be greater than <\(expectedValue)>")
    }
}

func beGreaterThan<T>(expectedValue: T) -> PartialMatcher<T, _BeGreaterThan<T>> {
    return PartialMatcher(matcher: _BeGreaterThan(expectedValue: expectedValue))
}

func ><T: Comparable>(lhs: _Expectation<T>, rhs: T) -> Bool {
    lhs.to(beGreaterThan(rhs))
    return true
}
