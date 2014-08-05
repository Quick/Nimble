import Foundation

public func beLessThanOrEqualTo<T: Comparable>(expectedValue: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than or equal to <\(expectedValue)>"
        return actualExpression.evaluate() <= expectedValue
    }
}

public func beLessThanOrEqualTo<T: NMBComparable>(expectedValue: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than or equal to <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        return actualValue != nil && actualValue!.NMB_compare(expectedValue) != NSComparisonResult.OrderedDescending
    }
}

public func <=<T: Comparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beLessThanOrEqualTo(rhs))
    return true
}

public func <=<T: NMBComparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beLessThanOrEqualTo(rhs))
    return true
}

extension NMBObjCMatcher {
    public class func beLessThanOrEqualToMatcher(expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as NMBComparable? })
            let expr = Expression(expression: block, location: location)
            return beLessThanOrEqualTo(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
