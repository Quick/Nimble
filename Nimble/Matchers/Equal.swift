import Foundation

public struct _EqualMatcher<T: Equatable>: BasicMatcher {
    let expectedValue: T?

    public func matches(actualExpression: Expression<T?>, failureMessage: FailureMessage) -> Bool  {
        failureMessage.postfixMessage = "equal <\(expectedValue)>"
        let matches = actualExpression.evaluate() == expectedValue && expectedValue != nil
        if !matches && expectedValue == nil {
            failureMessage.postfixMessage = " (will not match nils, use beNil() instead)"
        }
        return matches
    }
}

public func equal<T: Equatable>(expectedValue: T?) -> _EqualMatcher<T> {
    return _EqualMatcher(expectedValue: expectedValue)
}

public func ==<T: Equatable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.to(equal(rhs))
    return true
}

public func !=<T: Equatable>(lhs: Expectation<T?>, rhs: T?) -> Bool {
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

extension Array: Equatable {
}

public func ==<T>(lhs: Array<T>, rhs: Array<T>) -> Bool {
    return lhs.bridgeToObjectiveC() == rhs.bridgeToObjectiveC()
}
