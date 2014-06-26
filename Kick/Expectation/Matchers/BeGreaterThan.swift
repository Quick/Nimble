import Foundation

struct _BeGreaterThanMatcher<T: Comparable>: BasicMatcher {
    let expectedValue: T

    func matches(actualExpression: Expression<T>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (actualValue > expectedValue, "be greater than <\(expectedValue)>")
    }
}

func beGreaterThan<T>(expectedValue: T) -> _BeGreaterThanMatcher<T> {
    return _BeGreaterThanMatcher(expectedValue: expectedValue)
}

func ><T: Comparable>(lhs: Expectation<T>, rhs: T) -> Bool {
    lhs.to(beGreaterThan(rhs))
    return true
}

