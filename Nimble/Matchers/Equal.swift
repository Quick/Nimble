import Foundation

struct _EqualMatcher<T: Equatable>: BasicMatcher {
    let expectedValue: T?

    func matches(actualExpression: Expression<T?>, failureMessage: FailureMessage) -> Bool  {
        failureMessage.postfixMessage = "equal <\(expectedValue)>"
        let matches = actualExpression.evaluate() == expectedValue && expectedValue != nil
        if !matches && expectedValue == nil {
            failureMessage.postfixMessage = " (will not match nils, use beNil() instead)"
        }
        return matches
    }
}

func equal<T>(expectedValue: T?) -> _EqualMatcher<T> {
    return _EqualMatcher(expectedValue: expectedValue)
}

func equal(expectedValue: NSObject) -> _EqualMatcher<NSObject> {
    return _EqualMatcher(expectedValue: expectedValue)
}

func equal<T: NMBComparable>(expectedValue: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        return actualValue && actualValue!.NMB_compare(expectedValue) == NSComparisonResult.OrderedSame
    }
}

func ==<T: Equatable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.to(equal(rhs))
    return true
}

func ==<T: NMBComparable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.to(equal(rhs))
    return true
}

func !=<T: Equatable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.toNot(equal(rhs))
    return true
}

func !=<T: NMBComparable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.toNot(equal(rhs))
    return true
}

extension NMBObjCMatcher {
    class func equalMatcher(expected: NSObject) -> NMBMatcher {
        return NMBObjCMatcher { actualExpression, failureMessage, location in
            let expr = Expression(expression: actualExpression, location: location)
            return equal(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
