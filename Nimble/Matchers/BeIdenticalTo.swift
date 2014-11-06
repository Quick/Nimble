import Foundation


public func beIdenticalTo<T: AnyObject>(expected: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        let actual = actualExpression.evaluate()
        failureMessage.actualValue = "\(_identityAsString(actual))"
        failureMessage.postfixMessage = "be identical to \(_identityAsString(expected))"
        return actual === expected && actual !== nil
    }
}

public func ===<T: AnyObject>(lhs: Expectation<T>, rhs: T?) {
    lhs.to(beIdenticalTo(rhs))
}
public func !==<T: AnyObject>(lhs: Expectation<T>, rhs: T?) {
    lhs.toNot(beIdenticalTo(rhs))
}

extension NMBObjCMatcher {
    public class func beIdenticalToMatcher(expected: NSObject?) -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as NSObject? })
            let expr = Expression(expression: block, location: location)
            let matcher = NonNilMatcherWrapper(NonNilBasicMatcherWrapper(beIdenticalTo(expected)))
            return matcher.matches(expr, failureMessage: failureMessage)
        }
    }
}
