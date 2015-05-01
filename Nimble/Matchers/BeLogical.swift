import Foundation

internal func beBool(#expectedValue: BooleanType, #stringValue: String, #falseMatchesNil: Bool) -> MatcherFunc<BooleanType> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be \(stringValue)"
        let actual = actualExpression.evaluate()
        if expectedValue {
            return actual?.boolValue == expectedValue.boolValue
        } else if !falseMatchesNil {
            return actual != nil && actual!.boolValue != !expectedValue.boolValue
        } else {
            return actual?.boolValue != !expectedValue.boolValue
        }
    }
}

func matcherWithFailureMessage<T, M: Matcher where M.ValueType == T>(matcher: M, postprocessor: (FailureMessage) -> Void) -> FullMatcherFunc<T> {
    return FullMatcherFunc { actualExpression, failureMessage, isNegation in
        let pass: Bool
        if isNegation {
            pass = matcher.doesNotMatch(actualExpression, failureMessage: failureMessage)
        } else {
            pass = matcher.matches(actualExpression, failureMessage: failureMessage)
        }
        postprocessor(failureMessage)
        return pass
    }
}

// MARK: beTrue() / beFalse()

/// A Nimble matcher that succeeds when the actual value is exactly true.
/// This matcher will not match against nils.
public func beTrue() -> FullMatcherFunc<Bool> {
    return matcherWithFailureMessage(equal(true)) { failureMessage in
        failureMessage.postfixMessage = "be true"
    }
}

/// A Nimble matcher that succeeds when the actual value is exactly false.
/// This matcher will not match against nils.
public func beFalse() -> FullMatcherFunc<Bool> {
    return matcherWithFailureMessage(equal(false)) { failureMessage in
        failureMessage.postfixMessage = "be false"
    }
}

// MARK: beTruthy() / beFalsy()

/// A Nimble matcher that succeeds when the actual value is not logically false.
public func beTruthy() -> MatcherFunc<BooleanType> {
    return beBool(expectedValue: true, stringValue: "truthy", falseMatchesNil: true)
}

/// A Nimble matcher that succeeds when the actual value is logically false.
/// This matcher will match against nils.
public func beFalsy() -> MatcherFunc<BooleanType> {
    return beBool(expectedValue: false, stringValue: "falsy", falseMatchesNil: true)
}

extension NMBObjCMatcher {
    public class func beTruthyMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher { actualExpression, failureMessage in
            let expr = actualExpression.cast { ($0 as? NSNumber)?.boolValue ?? false as BooleanType? }
            return beTruthy().matches(expr, failureMessage: failureMessage)
        }
    }

    public class func beFalsyMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher { actualExpression, failureMessage in
            let expr = actualExpression.cast { ($0 as? NSNumber)?.boolValue ?? false as BooleanType? }
            return beFalsy().matches(expr, failureMessage: failureMessage)
        }
    }

    public class func beTrueMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher { actualExpression, failureMessage in
            let expr = actualExpression.cast { ($0 as? NSNumber)?.boolValue ?? false as Bool? }
            return beTrue().matches(expr, failureMessage: failureMessage)
        }
    }

    public class func beFalseMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let expr = actualExpression.cast { ($0 as? NSNumber)?.boolValue ?? false as Bool? }
            return beFalse().matches(expr, failureMessage: failureMessage)
        }
    }
}
