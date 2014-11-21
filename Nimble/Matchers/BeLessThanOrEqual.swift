import Foundation

public func beLessThanOrEqualTo<T: Comparable>(expectedValue: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than or equal to <\(stringify(expectedValue))>"
        return actualExpression.evaluate() <= expectedValue
    }
}

public func beLessThanOrEqualTo<T: NMBComparable>(expectedValue: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than or equal to <\(stringify(expectedValue))>"
        let actualValue = actualExpression.evaluate()
        return actualValue != nil && actualValue!.NMB_compare(expectedValue) != NSComparisonResult.OrderedDescending
    }
}

public func <=<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThanOrEqualTo(rhs))
}

public func <=<T: NMBComparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThanOrEqualTo(rhs))
}

extension NMBObjCMatcher {
    public class func beLessThanOrEqualToMatcher(expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil:false) { actualExpression, failureMessage, location in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return beLessThanOrEqualTo(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
