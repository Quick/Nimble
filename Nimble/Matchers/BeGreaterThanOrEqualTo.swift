import Foundation

func beGreaterThanOrEqualTo<T: Comparable>(expectedValue: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than or equal to <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        return actualValue >= expectedValue
    }
}

func beGreaterThanOrEqualTo<T: NMBComparable>(expectedValue: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than or equal to <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        let matches = actualValue && actualValue!.NMB_compare(expectedValue) != NSComparisonResult.OrderedAscending
        return matches
    }
}

func >=<T: Comparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beGreaterThanOrEqualTo(rhs))
    return true
}

func >=<T: NMBComparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beGreaterThanOrEqualTo(rhs))
    return true
}

extension NMBObjCMatcher {
    public class func beGreaterThanOrEqualToMatcher(expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as NMBComparable? })
            let expr = Expression(expression: block, location: location)
            return beGreaterThanOrEqualTo(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
