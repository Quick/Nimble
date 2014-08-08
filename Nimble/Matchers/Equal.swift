import Foundation

public func equal<T: Equatable>(expectedValue: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(expectedValue)>"
        let matches = actualExpression.evaluate() == expectedValue && expectedValue.hasValue
        if !expectedValue.hasValue || !actualExpression.evaluate().hasValue {
            failureMessage.postfixMessage += " (will not match nils, use beNil() instead)"
            return false
        }
        return matches
    }
}

// perhaps try to extend to SequenceOf or Sequence types instead of arrays
public func equal<T: Equatable>(expectedValue: [T]?) -> MatcherFunc<[T]?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(expectedValue)>"
        if !expectedValue.hasValue || !actualExpression.evaluate().hasValue {
            failureMessage.postfixMessage += " (will not match nils, use beNil() instead)"
            return false
        }
        var expectedGen = expectedValue!.generate()
        var actualGen = actualExpression.evaluate()!.generate()
        var expectedItem = expectedGen.next()
        var actualItem = actualGen.next()
        var matches = actualItem == expectedItem
        while (matches && (actualItem.hasValue || expectedItem.hasValue)) {
            actualItem = actualGen.next()
            expectedItem = expectedGen.next()
            matches = actualItem == expectedItem
        }
        return matches
    }
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
