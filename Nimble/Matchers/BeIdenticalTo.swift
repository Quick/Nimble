import Foundation


public func beIdenticalTo<T: NSObject>(expected: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        let actual = actualExpression.evaluate()
        failureMessage.actualValue = "\(_identityAsString(actual))"
        failureMessage.postfixMessage = "be identical to \(_identityAsString(expected))"
        let matches = actual === expected && actual !== nil
        if !matches && actual === nil {
            failureMessage.postfixMessage += " (will not compare nils, use beNil() instead)"
        }
        return matches
    }
}

public func ===<T: NSObject>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.to(beIdenticalTo(rhs))
    return true
}
public func !==<T: NSObject>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.toNot(beIdenticalTo(rhs))
    return true
}

extension NMBObjCMatcher {
    public class func beIdenticalToMatcher(expected: NSObject?) -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as NSObject? })
            let expr = Expression(expression: block, location: location)
            return beIdenticalTo(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
