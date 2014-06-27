import Foundation

func beGreaterThan<T: Comparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return DefineMatcher { actualExpression in
        let actualValue = actualExpression.evaluate()
        return (actualValue > expectedValue, "be greater than <\(expectedValue)>")
    }
}

func beGreaterThan<T: KICComparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return DefineMatcher { actualExpression in
        let actualValue = actualExpression.evaluate()
        let matches = actualValue && actualValue!.KIC_compare(expectedValue) == NSComparisonResult.OrderedDescending
        return (matches, "be greater than <\(expectedValue)>")
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
