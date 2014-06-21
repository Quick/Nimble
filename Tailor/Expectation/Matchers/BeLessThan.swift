import Foundation

struct _BeLessThan<T: Comparable>: Matcher {
    let expectedValue: T

    func matches(actualExpression: Expression<T>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (actualValue < expectedValue, "be less than <\(expectedValue)>")
    }
}

func beLessThan<T>(expectedValue: T) -> _BeLessThan<T> {
    return _BeLessThan(expectedValue: expectedValue)
}

func <<T: Comparable>(lhs: Expectation<T>, rhs: T) -> Bool {
    lhs.to(beLessThan(rhs))
    return true
}
