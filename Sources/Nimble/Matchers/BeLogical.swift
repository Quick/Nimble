import Foundation

internal func rename<T>(_ matcher: Matcher<T>, failureMessage message: ExpectationMessage) -> Matcher<T> {
    return Matcher { actualExpression in
        let result = try matcher.satisfies(actualExpression)
        return MatcherResult(status: result.status, message: message)
    }.requireNonNil
}

// MARK: beTrue() / beFalse()

/// A Nimble matcher that succeeds when the actual value is exactly true.
/// This matcher will not match against nils.
public func beTrue() -> Matcher<Bool> {
    return rename(equal(true), failureMessage: .expectedActualValueTo("be true"))
}

/// A Nimble matcher that succeeds when the actual value is exactly false.
/// This matcher will not match against nils.
public func beFalse() -> Matcher<Bool> {
    return rename(equal(false), failureMessage: .expectedActualValueTo("be false"))
}

// MARK: beTruthy() / beFalsy()

/// A Nimble matcher that succeeds when the actual value is not logically false.
public func beTruthy<T: ExpressibleByBooleanLiteral & Equatable>() -> Matcher<T> {
    return Matcher.simpleNilable("be truthy") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        return MatcherStatus(bool: actualValue == (true as T))
    }
}

/// A Nimble matcher that succeeds when the actual value is logically false.
/// This matcher will match against nils.
public func beFalsy<T: ExpressibleByBooleanLiteral & Equatable>() -> Matcher<T> {
    return Matcher.simpleNilable("be falsy") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        return MatcherStatus(bool: actualValue != (true as T))
    }
}

#if canImport(Darwin)
extension NMBMatcher {
    @objc public class func beTruthyMatcher() -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let expr = actualExpression.cast { ($0 as? NSNumber)?.boolValue ?? false }
            return try beTruthy().satisfies(expr).toObjectiveC()
        }
    }

    @objc public class func beFalsyMatcher() -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let expr = actualExpression.cast { ($0 as? NSNumber)?.boolValue ?? false }
            return try beFalsy().satisfies(expr).toObjectiveC()
        }
    }

    @objc public class func beTrueMatcher() -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let expr = actualExpression.cast { ($0 as? NSNumber)?.boolValue ?? false }
            return try beTrue().satisfies(expr).toObjectiveC()
        }
    }

    @objc public class func beFalseMatcher() -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let expr = actualExpression.cast { value -> Bool? in
                guard let value = value else { return nil }
                return (value as? NSNumber)?.boolValue ?? false
            }
            return try beFalse().satisfies(expr).toObjectiveC()
        }
    }
}
#endif
