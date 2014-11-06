import Foundation

public func beGreaterThanOrEqualTo<T: Comparable>(expectedValue: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than or equal to <\(stringify(expectedValue))>"
        let actualValue = actualExpression.evaluate()
        return actualValue >= expectedValue
    }
}

public func beGreaterThanOrEqualTo<T: NMBComparable>(expectedValue: T?) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than or equal to <\(stringify(expectedValue))>"
        let actualValue = actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) != NSComparisonResult.OrderedAscending
        return matches
    }
}

public func >=<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beGreaterThanOrEqualTo(rhs))
}

public func >=<T: NMBComparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beGreaterThanOrEqualTo(rhs))
}

extension NMBObjCMatcher {
    public class func beGreaterThanOrEqualToMatcher(expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as NMBComparable? })
            let expr = Expression(expression: block, location: location)
            let matcher = NonNilMatcherWrapper(NonNilBasicMatcherWrapper(beGreaterThanOrEqualTo(expected)))
            return matcher.matches(expr, failureMessage: failureMessage)
        }
    }
}
