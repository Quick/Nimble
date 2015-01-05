import Foundation

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T: Equatable>(expectedValue: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"
        let matches = actualExpression.evaluate() == expectedValue && expectedValue != nil
        if expectedValue == nil || actualExpression.evaluate() == nil {
            if expectedValue == nil {
                failureMessage.postfixActual = " (use beNil() to match nils)"
            }
            return false
        }
        return matches
    }
}

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T: Equatable, C: Equatable>(expectedValue: [T: C]?) -> NonNilMatcherFunc<[T: C]> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"
        if expectedValue == nil || actualExpression.evaluate() == nil {
            if expectedValue == nil {
                failureMessage.postfixActual = " (use beNil() to match nils)"
            }
            return false
        }
        return expectedValue! == actualExpression.evaluate()!
    }
}

/// A Nimble matcher that succeeds when the actual collection is equal to the expected collection.
/// Items must implement the Equatable protocol.
public func equal<T: Equatable>(expectedValue: [T]?) -> NonNilMatcherFunc<[T]> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"
        if expectedValue == nil || actualExpression.evaluate() == nil {
            if expectedValue == nil {
                failureMessage.postfixActual = " (use beNil() to match nils)"
            }
            return false
        }
        return expectedValue! == actualExpression.evaluate()!
    }
}

public func ==<T: Equatable>(lhs: Expectation<T>, rhs: T?) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: Expectation<T>, rhs: T?) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Equatable>(lhs: Expectation<[T]>, rhs: [T]?) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: Expectation<[T]>, rhs: [T]?) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Equatable, C: Equatable>(lhs: Expectation<[T: C]>, rhs: [T: C]?) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable, C: Equatable>(lhs: Expectation<[T: C]>, rhs: [T: C]?) {
    lhs.toNot(equal(rhs))
}

extension NMBObjCMatcher {
    public class func equalMatcher(expected: NSObject) -> NMBMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage, location in
            return equal(expected).matches(actualExpression, failureMessage: failureMessage)
        }
    }
}
