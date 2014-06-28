import Foundation

struct _EqualMatcher<T: Equatable>: BasicMatcher {
    let expectedValue: T?

    func matches(actualExpression: Expression<T?>, failureMessage: FailureMessage) -> Bool  {
        failureMessage.postfixMessage = "equal <\(expectedValue)>"
        return actualExpression.evaluate() == expectedValue
    }
}

func equal<T>(expectedValue: T?) -> _EqualMatcher<T> {
    return _EqualMatcher(expectedValue: expectedValue)
}

func equal<T: KICComparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        return actualValue && actualValue!.KIC_compare(expectedValue) == NSComparisonResult.OrderedSame
    }
}

func equal(expectedValue: NSObject) -> _EqualMatcher<NSObject> {
    return _EqualMatcher(expectedValue: expectedValue)
}

func ==<T: Equatable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.to(equal(rhs))
    return true
}

func ==<T: KICComparable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.to(equal(rhs))
    return true
}

func !=<T: Equatable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.toNot(equal(rhs))
    return true
}

func !=<T: KICComparable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.toNot(equal(rhs))
    return true
}
