import Foundation

struct _EqualMatcher<T: Equatable>: BasicMatcher {
    let expectedValue: T?

    func matches(actualExpression: Expression<T?>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (actualValue == expectedValue, "equal <\(expectedValue)>")
    }
}

struct _EqualComparableMatcher<T: KICComparable>: BasicMatcher {
    let expectedValue: T?

    func matches(actualExpression: Expression<T?>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        let matches = actualValue && actualValue!.KIC_compare(expectedValue) == NSComparisonResult.OrderedSame
        return (matches, "equal <\(expectedValue)>")
    }
}

func equal<T>(expectedValue: T?) -> _EqualMatcher<T> {
    return _EqualMatcher(expectedValue: expectedValue)
}

func equal<T>(expectedValue: T?) -> _EqualComparableMatcher<T> {
    return _EqualComparableMatcher(expectedValue: expectedValue)
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
