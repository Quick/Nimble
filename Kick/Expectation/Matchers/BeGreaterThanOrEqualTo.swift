import Foundation

func beGreaterThanOrEqualTo<T: Comparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return DefineMatcher { actualExpression in
        let actualValue = actualExpression.evaluate()
        return (actualValue >= expectedValue, "be greater than or equal to <\(expectedValue)>")
    }
}

func beGreaterThanOrEqualTo<T: KICComparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return DefineMatcher { actualExpression in
        let actualValue = actualExpression.evaluate()
        let matches = actualValue && actualValue!.KIC_compare(expectedValue) != NSComparisonResult.OrderedAscending
        return (matches, "be greater than or equal to <\(expectedValue)>")
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
