/// A Nimble matcher that succeeds when the actual value is greater than
/// or equal to the expected value.
public func beGreaterThanOrEqualTo<T: Comparable>(_ expectedValue: T?) -> Matcher<T> {
    let message = "be greater than or equal to <\(stringify(expectedValue))>"
    return Matcher.simple(message) { actualExpression in
        guard let actual = try actualExpression.evaluate(), let expected = expectedValue else { return .fail }

        return MatcherStatus(bool: actual >= expected)
    }
}

public func >= <T: Comparable>(lhs: SyncExpectation<T>, rhs: T) {
    lhs.to(beGreaterThanOrEqualTo(rhs))
}

public func >= <T: Comparable>(lhs: AsyncExpectation<T>, rhs: T) async {
    await lhs.to(beGreaterThanOrEqualTo(rhs))
}

#if canImport(Darwin)
import enum Foundation.ComparisonResult

/// A Nimble matcher that succeeds when the actual value is greater than
/// or equal to the expected value.
public func beGreaterThanOrEqualTo<T: NMBComparable>(_ expectedValue: T?) -> Matcher<T> {
    let message = "be greater than or equal to <\(stringify(expectedValue))>"
    return Matcher.simple(message) { actualExpression in
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) != ComparisonResult.orderedAscending
        return MatcherStatus(bool: matches)
    }
}

public func >= <T: NMBComparable>(lhs: SyncExpectation<T>, rhs: T) {
    lhs.to(beGreaterThanOrEqualTo(rhs))
}

public func >= <T: NMBComparable>(lhs: AsyncExpectation<T>, rhs: T) async {
    await lhs.to(beGreaterThanOrEqualTo(rhs))
}

extension NMBMatcher {
    @objc public class func beGreaterThanOrEqualToMatcher(_ expected: NMBComparable?) -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try beGreaterThanOrEqualTo(expected).satisfies(expr).toObjectiveC()
        }
    }
}
#endif
