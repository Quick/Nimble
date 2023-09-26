/// A Nimble matcher that succeeds when the actual value is less than the expected value.
public func beLessThan<T: Comparable>(_ expectedValue: T?) -> Matcher<T> {
    let message = "be less than <\(stringify(expectedValue))>"
    return Matcher.simple(message) { actualExpression in
        guard let actual = try actualExpression.evaluate(), let expected = expectedValue else { return .fail }

        return MatcherStatus(bool: actual < expected)
    }
}

public func < <V: Comparable>(lhs: SyncExpectation<V>, rhs: V) {
    lhs.to(beLessThan(rhs))
}

public func < <V: Comparable>(lhs: AsyncExpectation<V>, rhs: V) async {
    await lhs.to(beLessThan(rhs))
}

#if canImport(Darwin)
import enum Foundation.ComparisonResult

/// A Nimble matcher that succeeds when the actual value is less than the expected value.
public func beLessThan<T: NMBComparable>(_ expectedValue: T?) -> Matcher<T> {
    let message = "be less than <\(stringify(expectedValue))>"
    return Matcher.simple(message) { actualExpression in
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) == ComparisonResult.orderedAscending
        return MatcherStatus(bool: matches)
    }
}

public func < <V: NMBComparable>(lhs: SyncExpectation<V>, rhs: V?) {
    lhs.to(beLessThan(rhs))
}

public func < <V: NMBComparable>(lhs: AsyncExpectation<V>, rhs: V?) async {
    await lhs.to(beLessThan(rhs))
}

extension NMBMatcher {
    @objc public class func beLessThanMatcher(_ expected: NMBComparable?) -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try beLessThan(expected).satisfies(expr).toObjectiveC()
        }
    }
}
#endif
