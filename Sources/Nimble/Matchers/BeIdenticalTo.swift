/// A Nimble matcher that succeeds when the actual value is the same instance
/// as the expected instance.
public func beIdenticalTo(_ expected: AnyObject?) -> Matcher<AnyObject> {
    return Matcher.define { actualExpression in
        let actual = try actualExpression.evaluate()

        let bool = actual === expected && actual !== nil
        return MatcherResult(
            bool: bool,
            message: .expectedCustomValueTo(
                "be identical to \(identityAsString(expected))",
                actual: "\(identityAsString(actual))"
            )
        )
    }
}

public func === (lhs: SyncExpectation<AnyObject>, rhs: AnyObject?) {
    lhs.to(beIdenticalTo(rhs))
}

public func === (lhs: AsyncExpectation<AnyObject>, rhs: AnyObject?) async {
    await lhs.to(beIdenticalTo(rhs))
}

public func !== (lhs: SyncExpectation<AnyObject>, rhs: AnyObject?) {
    lhs.toNot(beIdenticalTo(rhs))
}

public func !== (lhs: AsyncExpectation<AnyObject>, rhs: AnyObject?) async {
    await lhs.toNot(beIdenticalTo(rhs))
}

/// A Nimble matcher that succeeds when the actual value is the same instance
/// as the expected instance.
///
/// Alias for "beIdenticalTo".
public func be(_ expected: AnyObject?) -> Matcher<AnyObject> {
    return beIdenticalTo(expected)
}

#if canImport(Darwin)
import class Foundation.NSObject

extension NMBMatcher {
    @objc public class func beIdenticalToMatcher(_ expected: NSObject?) -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let aExpr = actualExpression.cast { $0 as AnyObject? }
            return try beIdenticalTo(expected).satisfies(aExpr).toObjectiveC()
        }
    }
}
#endif
