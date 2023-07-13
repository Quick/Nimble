/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the variable list of matchers.
public func satisfyAnyOf<T>(_ predicates: Predicate<T>...) -> Predicate<T> {
    return satisfyAnyOf(predicates)
}

/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the array of matchers.
public func satisfyAnyOf<T>(_ predicates: [Predicate<T>]) -> Predicate<T> {
    return Predicate.define { actualExpression in
        let cachedExpression = actualExpression.withCaching()
        var postfixMessages = [String]()
        var status: PredicateStatus = .doesNotMatch
        for predicate in predicates {
            let result = try predicate.satisfies(cachedExpression)
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

        return PredicateResult(status: status, message: msg)
    }
}

public func || <T>(left: Predicate<T>, right: Predicate<T>) -> Predicate<T> {
    return satisfyAnyOf(left, right)
}

// There's a compiler bug in swift 5.7.2 and earlier (xcode 14.2 and earlier)
// which causes runtime crashes when you use `[any AsyncablePredicate<T>]`.
// https://github.com/apple/swift/issues/61403
#if swift(>=5.8.0)
/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the variable list of matchers.
@available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
public func satisfyAnyOf<T>(_ predicates: any AsyncablePredicate<T>...) -> AsyncPredicate<T> {
    return satisfyAnyOf(predicates)
}

/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the array of matchers.
@available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
public func satisfyAnyOf<T>(_ predicates: [any AsyncablePredicate<T>]) -> AsyncPredicate<T> {
    return AsyncPredicate.define { actualExpression in
        let cachedExpression = actualExpression.withCaching()
        var postfixMessages = [String]()
        var status: PredicateStatus = .doesNotMatch
        for predicate in predicates {
            let result = try await predicate.satisfies(cachedExpression)
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

        return PredicateResult(status: status, message: msg)
    }
}

@available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
public func || <T>(left: some AsyncablePredicate<T>, right: some AsyncablePredicate<T>) -> AsyncPredicate<T> {
    return satisfyAnyOf(left, right)
}
#endif // swift(>=5.8.0)

#if canImport(Darwin)
import class Foundation.NSObject

extension NMBPredicate {
    @objc public class func satisfyAnyOfMatcher(_ predicates: [NMBPredicate]) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            if predicates.isEmpty {
                return NMBPredicateResult(
                    status: NMBPredicateStatus.fail,
                    message: NMBExpectationMessage(
                        fail: "satisfyAnyOf must be called with at least one matcher"
                    )
                )
            }

            var elementEvaluators = [Predicate<NSObject>]()
            for predicate in predicates {
                let elementEvaluator = Predicate<NSObject> { expression in
                    return predicate.satisfies({ try expression.evaluate() }, location: actualExpression.location).toSwift()
                }

                elementEvaluators.append(elementEvaluator)
            }

            return try satisfyAnyOf(elementEvaluators).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
