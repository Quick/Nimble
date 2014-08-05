import Foundation

public func beGreaterThan<T: Comparable>(expectedValue: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than <\(expectedValue)>"
        return actualExpression.evaluate() > expectedValue
    }
}

public func beGreaterThan(expectedValue: NMBComparable?) -> MatcherFunc<NMBComparable?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) == NSComparisonResult.OrderedDescending
        return matches
    }
}

public func ><T: Comparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beGreaterThan(rhs))
    return true
}

public func >(lhs: Expectation<NMBComparable?>, rhs: NMBComparable?) -> Bool {
    lhs.to(beGreaterThan(rhs))
    return true
}

extension NMBObjCMatcher {
    public class func beGreaterThanMatcher(expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as NMBComparable? })
            let expr = Expression(expression: block, location: location)
            return beGreaterThan(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
