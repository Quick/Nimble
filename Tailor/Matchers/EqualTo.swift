import Foundation

struct _Equal<T: Equatable>: Matcher {
    let expectedValue: T

    func matches(actualExpression: Expression<T>) -> (pass: Bool, messagePostfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (actualValue == expectedValue, "equal to <\(expectedValue)>")
    }
}

func equalTo<T>(expectedValue: T) -> _Equal<T> {
    return _Equal(expectedValue: expectedValue)
}

func equalTo(expectedValue: AnyObject) -> _Equal<NSObject> {
    return _Equal(expectedValue: expectedValue as NSObject)
}

func ==<T: Equatable>(lhs: Expectation<T>, rhs: T) -> Bool {
    lhs.to(equalTo(rhs))
    return true
}

func !=<T: Equatable>(lhs: Expectation<T>, rhs: T) -> Bool {
    lhs.toNot(equalTo(rhs))
    return true
}
