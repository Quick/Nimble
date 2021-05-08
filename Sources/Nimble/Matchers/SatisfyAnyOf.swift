/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the variable list of matchers.
public func satisfyAnyOf<T>(_ predicates: Predicate<T>...) -> Predicate<T> {
    return satisfyAnyOf(predicates)
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
