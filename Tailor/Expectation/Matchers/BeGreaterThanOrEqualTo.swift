import Foundation

struct _BeGreaterThanOrEqual<T: Comparable>: Matcher {
    let expectedValue: T

    func matches(actualExpression: Expression<T>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (actualValue >= expectedValue, "be greater than or equal to <\(expectedValue)>")
    }
}

func beGreaterThanOrEqualTo<T: Comparable>(expectedValue: T) -> _BeGreaterThanOrEqual<T> {
    return _BeGreaterThanOrEqual(expectedValue: expectedValue)
}

func >=<T: Comparable>(lhs: Expectation<T>, rhs: T) -> Bool {
    lhs.to(beGreaterThanOrEqualTo(rhs))
    return true
}