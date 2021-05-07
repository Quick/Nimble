/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the variable list of matchers.
public func satisfyAnyOf<T>(_ predicates: Predicate<T>...) -> Predicate<T> {
    return satisfyAnyOf(predicates)
}

/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the variable list of matchers. 
@available(*, deprecated, message: "Use Predicate instead")
public func satisfyAnyOf<T, U>(_ matchers: U...) -> Predicate<T>
    where U: Matcher, U.ValueType == T {
        return satisfyAnyOf(matchers.map { $0.predicate })
}

/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the array of matchers.
public func satisfyAnyOf<T>(_ predicates: [Predicate<T>]) -> Predicate<T> {
        return Predicate.define { actualExpression in
            var postfixMessages = [String]()
            var status: PredicateStatus = .doesNotMatch
            for predicate in predicates {
                let result = try predicate.satisfies(actualExpression)
                if result.status == .fail {
                    status = .fail
                } else if result.status == .matches, status != .fail {
                    status = .matches
                }
                postfixMessages.append("{\(result.message.expectedMessage)}")
            }

            var msg: ExpectationMessage
            if let actualValue = try actualExpression.evaluate() {
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

@available(*, deprecated, message: "Use Predicate instead")
public func || <T>(left: NonNilMatcherFunc<T>, right: NonNilMatcherFunc<T>) -> Predicate<T> {
    return satisfyAnyOf(left, right)
}

@available(*, deprecated, message: "Use Predicate instead")
public func || <T>(left: MatcherFunc<T>, right: MatcherFunc<T>) -> Predicate<T> {
    return satisfyAnyOf(left, right)
}

#if canImport(Darwin)
import class Foundation.NSObject

extension NMBPredicate {
    @objc public class func satisfyAnyOfMatcher(_ matchers: [NMBMatcher]) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            if matchers.isEmpty {
                return NMBPredicateResult(
                    status: NMBPredicateStatus.fail,
                    message: NMBExpectationMessage(
                        fail: "satisfyAnyOf must be called with at least one matcher"
                    )
                )
            }

            var elementEvaluators = [Predicate<NSObject>]()
            for matcher in matchers {
                let elementEvaluator = Predicate<NSObject> { expression in
                    if let predicate = matcher as? NMBPredicate {
                        return predicate.satisfies({ try expression.evaluate() }, location: actualExpression.location).toSwift()
                    } else {
                        let failureMessage = FailureMessage()
                        let success = matcher.matches(
                            // swiftlint:disable:next force_try
                            { try! expression.evaluate() },
                            failureMessage: failureMessage,
                            location: actualExpression.location
                        )
                        return PredicateResult(bool: success, message: failureMessage.toExpectationMessage())
                    }
                }

                elementEvaluators.append(elementEvaluator)
            }

            return try satisfyAnyOf(elementEvaluators).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
