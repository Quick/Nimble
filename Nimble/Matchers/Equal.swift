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

func equal<T: Equatable>(expectedValue: T?) -> _EqualMatcher<T> {
    return _EqualMatcher(expectedValue: expectedValue)
}

func ==<T: Equatable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.to(equal(rhs))
    return true
}

func !=<T: Equatable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.toNot(equal(rhs))
    return true
}

extension NMBObjCMatcher {
    public class func equalMatcher(expected: NSObject) -> NMBMatcher {
        return NMBObjCMatcher { actualExpression, failureMessage, location in
            let expr = Expression(expression: actualExpression, location: location)
            return equal(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
