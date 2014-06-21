import Foundation

struct _Equal<T: Equatable>: Matcher {
    let expectedValue: T?

    func matches(actualExpression: Expression<T?>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (actualValue == expectedValue, "equal <\(expectedValue)>")
    }
}

func equal<T>(expectedValue: T?) -> _Equal<T> {
    return _Equal(expectedValue: expectedValue)
}

func equal(expectedValue: NSObject) -> _Equal<NSObject> {
    return _Equal(expectedValue: expectedValue)
}

func ==<T: Equatable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.to(equal(rhs))
    return true
}

func !=<T: Equatable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.toNot(equal(rhs))
    return true
}
