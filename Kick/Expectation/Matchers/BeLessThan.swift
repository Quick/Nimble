import Foundation

func beLessThan<T: Comparable>(expectedValue: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than <\(expectedValue)>"
        return actualExpression.evaluate() < expectedValue
    }
}

func beLessThan(expectedValue: KICComparable?) -> MatcherFunc<KICComparable?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        let matches = actualValue && actualValue!.KIC_compare(expectedValue) == NSComparisonResult.OrderedAscending
        return matches
    }
}

func <<T: Comparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beLessThan(rhs))
    return true
}

func <(lhs: Expectation<KICComparable?>, rhs: KICComparable?) -> Bool {
    lhs.to(beLessThan(rhs))
    return true
}

extension KICObjCMatcher {
    class func beLessThanMatcher(expected: KICComparable?) -> KICObjCMatcher {
        return KICObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as KICComparable? })
            let expr = Expression(expression: block, location: location)
            return beLessThan(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
