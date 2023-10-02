/// A Nimble matcher that succeeds when the actual value matches with all of the matchers
/// provided in the variable list of matchers.
public func satisfyAllOf<T>(_ matchers: Matcher<T>...) -> Matcher<T> {
    return satisfyAllOf(matchers)
}

/// A Nimble matcher that succeeds when the actual value matches with all of the matchers
/// provided in the array of matchers.
public func satisfyAllOf<T>(_ matchers: [Matcher<T>]) -> Matcher<T> {
    return Matcher.define { actualExpression in
        let cachedExpression = actualExpression.withCaching()
        var postfixMessages = [String]()
        var status: MatcherStatus = .matches
        for matcher in matchers {
            let result = try matcher.satisfies(cachedExpression)
            if result.status == .fail {
                status = .fail
            } else if result.status == .doesNotMatch, status != .fail {
                status = .doesNotMatch
            }
            postfixMessages.append("{\(result.message.expectedMessage)}")
        }

        var msg: ExpectationMessage
        if let actualValue = try cachedExpression.evaluate() {
            msg = .expectedCustomValueTo(
                "match all of: " + postfixMessages.joined(separator: ", and "),
                actual: "\(actualValue)"
            )
        } else {
            msg = .expectedActualValueTo(
                "match all of: " + postfixMessages.joined(separator: ", and ")
            )
        }

        return MatcherResult(status: status, message: msg)
    }
}

public func && <T>(left: Matcher<T>, right: Matcher<T>) -> Matcher<T> {
    return satisfyAllOf(left, right)
}

// There's a compiler bug in swift 5.7.2 and earlier (xcode 14.2 and earlier)
// which causes runtime crashes when you use `[any AsyncableMatcher<T>]`.
// https://github.com/apple/swift/issues/61403
#if swift(>=5.8.0)
/// A Nimble matcher that succeeds when the actual value matches with all of the matchers
/// provided in the variable list of matchers.
@available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
public func satisfyAllOf<T>(_ matchers: any AsyncableMatcher<T>...) -> AsyncMatcher<T> {
    return satisfyAllOf(matchers)
}

/// A Nimble matcher that succeeds when the actual value matches with all of the matchers
/// provided in the array of matchers.
@available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
public func satisfyAllOf<T>(_ matchers: [any AsyncableMatcher<T>]) -> AsyncMatcher<T> {
    return AsyncMatcher.define { actualExpression in
        let cachedExpression = actualExpression.withCaching()
        var postfixMessages = [String]()
        var status: MatcherStatus = .matches
        for matcher in matchers {
            let result = try await matcher.satisfies(cachedExpression)
            if result.status == .fail {
                status = .fail
            } else if result.status == .doesNotMatch, status != .fail {
                status = .doesNotMatch
            }
            postfixMessages.append("{\(result.message.expectedMessage)}")
        }

        var msg: ExpectationMessage
        if let actualValue = try await cachedExpression.evaluate() {
            msg = .expectedCustomValueTo(
                "match all of: " + postfixMessages.joined(separator: ", and "),
                actual: "\(actualValue)"
            )
        } else {
            msg = .expectedActualValueTo(
                "match all of: " + postfixMessages.joined(separator: ", and ")
            )
        }

        return MatcherResult(status: status, message: msg)
    }
}

@available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
public func && <T>(left: some AsyncableMatcher<T>, right: some AsyncableMatcher<T>) -> AsyncMatcher<T> {
    return satisfyAllOf(left, right)
}
#endif // swift(>=5.8.0)

#if canImport(Darwin)
import class Foundation.NSObject

extension NMBMatcher {
    @objc public class func satisfyAllOfMatcher(_ matchers: [NMBMatcher]) -> NMBMatcher {
        return NMBMatcher { actualExpression in
            if matchers.isEmpty {
                return NMBMatcherResult(
                    status: NMBMatcherStatus.fail,
                    message: NMBExpectationMessage(
                        fail: "satisfyAllOf must be called with at least one matcher"
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

            return try satisfyAllOf(elementEvaluators).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
