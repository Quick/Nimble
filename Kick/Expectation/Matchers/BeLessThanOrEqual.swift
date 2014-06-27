import Foundation

func beLessThanOrEqualTo<T: Comparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return DefineMatcher { actualExpression in
        let actualValue = actualExpression.evaluate()
        return (actualValue <= expectedValue, "be less than or equal to <\(expectedValue)>")
    }
}

func beLessThanOrEqualTo<T: KICComparable>(expectedValue: T?) -> FuncMatcherWrapper<T?> {
    return DefineMatcher { actualExpression in
        let actualValue = actualExpression.evaluate()
        let matches = actualValue && actualValue!.KIC_compare(expectedValue) != NSComparisonResult.OrderedDescending
        return (matches, "be less than or equal to <\(expectedValue)>")
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
