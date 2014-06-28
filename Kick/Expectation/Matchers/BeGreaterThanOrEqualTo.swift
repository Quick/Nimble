import Foundation

func beGreaterThanOrEqualTo<T: Comparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than or equal to <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        return actualValue >= expectedValue
    }
}

func beGreaterThanOrEqualTo<T: KICComparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than or equal to <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        let matches = actualValue && actualValue!.KIC_compare(expectedValue) != NSComparisonResult.OrderedAscending
        return matches
    }
}

func >=<T: Comparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beGreaterThanOrEqualTo(rhs))
    return true
}

func >=<T: KICComparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beGreaterThanOrEqualTo(rhs))
    return true
}
