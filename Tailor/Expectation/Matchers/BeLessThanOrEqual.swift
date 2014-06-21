import Foundation

struct _BeLessThanOrEqual<T: Comparable>: Matcher {
    let expectedValue: T

    func matches(actualExpression: Expression<T>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (actualValue <= expectedValue, "be less than or equal to <\(expectedValue)>")
    }
}

func beLessThanOrEqualTo<T: Comparable>(expectedValue: T) -> _BeLessThanOrEqual<T> {
    return _BeLessThanOrEqual(expectedValue: expectedValue)
}

func <=<T: Comparable>(lhs: Expectation<T>, rhs: T) -> Bool {
    lhs.to(beLessThanOrEqualTo(rhs))
    return true
}