import Foundation

func beLessThanOrEqualTo<T: Comparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than or equal to <\(expectedValue)>"
        return actualExpression.evaluate() <= expectedValue
    }
}

func beLessThanOrEqualTo<T: KICComparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than or equal to <\(expectedValue)>"
        let actualValue = actualExpression.evaluate()
        return actualValue && actualValue!.KIC_compare(expectedValue) != NSComparisonResult.OrderedDescending
    }
}

func <=<T: Comparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beLessThanOrEqualTo(rhs))
    return true
}

func <=<T: KICComparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beLessThanOrEqualTo(rhs))
    return true
}
