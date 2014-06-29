import Foundation

func beGreaterThan<T: Comparable>(expectedValue: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than <\(expectedValue)>"
        return actualExpression.evaluate() > expectedValue
    }
}

func beGreaterThan<T: KICComparable>(expectedValue: T?) -> MatcherFunc<T?> {
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

func ><T: KICComparable>(lhs: Expectation<T?>, rhs: T) -> Bool {
    lhs.to(beGreaterThan(rhs))
    return true
}
