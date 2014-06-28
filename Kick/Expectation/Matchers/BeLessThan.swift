import Foundation

func beLessThan<T: Comparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than <\(expectedValue)>"
        return actualExpression.evaluate() < expectedValue
    }
}

func beLessThan<T: KICComparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
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

func <<T: KICComparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beLessThan(rhs))
    return true
}
