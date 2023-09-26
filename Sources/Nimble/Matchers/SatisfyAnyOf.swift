/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the variable list of matchers.
public func satisfyAnyOf<T>(_ matchers: Matcher<T>...) -> Matcher<T> {
    return satisfyAnyOf(matchers)
}

/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the array of matchers.
public func satisfyAnyOf<T>(_ matchers: [Matcher<T>]) -> Matcher<T> {
    return Matcher.define { actualExpression in
        let cachedExpression = actualExpression.withCaching()
        var postfixMessages = [String]()
        var status: MatcherStatus = .doesNotMatch
        for matcher in matchers {
            let result = try matcher.satisfies(cachedExpression)
            if result.status == .fail {
                status = .fail
            } else if result.status == .matches, status != .fail {
                status = .matches
            }
            postfixMessages.append("{\(result.message.expectedMessage)}")
        }

        var msg: ExpectationMessage
        if let actualValue = try cachedExpression.evaluate() {
            msg = .expectedCustomValueTo(
                "match one of: " + postfixMessages.joined(separator: ", or "),
                actual: "\(actualValue)"
            )
        } else {
            msg = .expectedActualValueTo(
                "match one of: " + postfixMessages.joined(separator: ", or ")
            )
        }

        return MatcherResult(status: status, message: msg)
    }
}

public func || <T>(left: Matcher<T>, right: Matcher<T>) -> Matcher<T> {
    return satisfyAnyOf(left, right)
}

// There's a compiler bug in swift 5.7.2 and earlier (xcode 14.2 and earlier)
// which causes runtime crashes when you use `[any AsyncableMatcher<T>]`.
// https://github.com/apple/swift/issues/61403
#if swift(>=5.8.0)
/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the variable list of matchers.
@available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
public func satisfyAnyOf<T>(_ matchers: any AsyncableMatcher<T>...) -> AsyncMatcher<T> {
    return satisfyAnyOf(matchers)
}

/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the array of matchers.
@available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
public func satisfyAnyOf<T>(_ matchers: [any AsyncableMatcher<T>]) -> AsyncMatcher<T> {
    return AsyncMatcher.define { actualExpression in
        let cachedExpression = actualExpression.withCaching()
        var postfixMessages = [String]()
        var status: MatcherStatus = .doesNotMatch
        for matcher in matchers {
            let result = try await matcher.satisfies(cachedExpression)
            if result.status == .fail {
                status = .fail
            } else if result.status == .matches, status != .fail {
                status = .matches
            }
            postfixMessages.append("{\(result.message.expectedMessage)}")
        }

        var msg: ExpectationMessage
        if let actualValue = try await cachedExpression.evaluate() {
            msg = .expectedCustomValueTo(
                "match one of: " + postfixMessages.joined(separator: ", or "),
                actual: "\(actualValue)"
            )
        } else {
            msg = .expectedActualValueTo(
                "match one of: " + postfixMessages.joined(separator: ", or ")
            )
        }

        return MatcherResult(status: status, message: msg)
    }
}

@available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
public func || <T>(left: some AsyncableMatcher<T>, right: some AsyncableMatcher<T>) -> AsyncMatcher<T> {
    return satisfyAnyOf(left, right)
}
#endif // swift(>=5.8.0)

#if canImport(Darwin)
import class Foundation.NSObject

extension NMBMatcher {
    @objc public class func satisfyAnyOfMatcher(_ matchers: [NMBMatcher]) -> NMBMatcher {
        return NMBMatcher { actualExpression in
            if matchers.isEmpty {
                return NMBMatcherResult(
                    status: NMBMatcherStatus.fail,
                    message: NMBExpectationMessage(
                        fail: "satisfyAnyOf must be called with at least one matcher"
                    )
                )
            }

            var elementEvaluators = [Matcher<NSObject>]()
            for matcher in matchers {
                let elementEvaluator = Matcher<NSObject> { expression in
                    return matcher.satisfies({ try expression.evaluate() }, location: actualExpression.location).toSwift()
                }

                elementEvaluators.append(elementEvaluator)
            }

            return try satisfyAnyOf(elementEvaluators).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
