import Foundation

func beGreaterThan<T: Comparable>(expectedValue: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than <\(expectedValue)>"
        return actualExpression.evaluate() > expectedValue
    }
}

func beGreaterThan(expectedValue: KICComparable?) -> MatcherFunc<KICComparable?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        let matches = actualValue && actualValue!.KIC_compare(expectedValue) == NSComparisonResult.OrderedDescending
        return matches
    }
}

func ><T: Comparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beGreaterThan(rhs))
    return true
}

func >(lhs: Expectation<KICComparable?>, rhs: KICComparable?) -> Bool {
    lhs.to(beGreaterThan(rhs))
    return true
}

extension KICObjCMatcher {
    class func beGreaterThanMatcher(expected: KICComparable?) -> KICObjCMatcher {
        return KICObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as KICComparable? })
            let expr = Expression(expression: block, location: location)
            return beGreaterThan(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
