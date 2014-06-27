import Foundation

func beLessThan<T: Comparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return DefineMatcher { actualExpression in
        let actualValue = actualExpression.evaluate()
        return (actualValue < expectedValue, "be less than <\(expectedValue)>")
    }
}

func beLessThan<T: KICComparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return DefineMatcher { actualExpression in
        let actualValue = actualExpression.evaluate()
        let matches = actualValue && actualValue!.KIC_compare(expectedValue) == NSComparisonResult.OrderedAscending
        return (matches, "be less than <\(expectedValue)>")
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
