import Foundation

struct _Equal<T: Equatable>: Matcher {
    let expectedValue: T

    func matches(actualExpression: () -> T) -> (pass: Bool, messagePostfix: String)  {
        let actualValue = actualExpression()
        return (actualValue == expectedValue, "equal to <\(expectedValue)>")
    }
}

func equalTo<T>(expectedValue: T) -> PartialMatcher<T, _Equal<T>> {
    return PartialMatcher(matcher: _Equal(expectedValue: expectedValue))
}

func equalTo(expectedValue: AnyObject) -> PartialMatcher<NSObject, _Equal<NSObject>> {
    return PartialMatcher(matcher: _Equal(expectedValue: expectedValue as NSObject))
}

func ==<T: Equatable>(lhs: _Expectation<T>, rhs: T) -> Bool {
    lhs.to(equalTo(rhs))
    return true
}

func !=<T: Equatable>(lhs: _Expectation<T>, rhs: T) -> Bool {
    lhs.toNot(equalTo(rhs))
    return true
}
