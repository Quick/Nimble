// The `haveCount` matchers do not print the full string representation of the collection value,
// instead they only print the type name and the expected count. This makes it easier to understand
// the reason for failed expectations. See: https://github.com/Quick/Nimble/issues/308.
// The representation of the collection content is provided in a new line as an `extendedMessage`.

/// A Nimble matcher that succeeds when the actual Collection's count equals
/// the expected value
public func haveCount<T: Collection>(_ expectedValue: Int) -> Matcher<T> {
    return Matcher.define { actualExpression in
        if let actualValue = try actualExpression.evaluate() {
            let message = ExpectationMessage
                .expectedCustomValueTo(
                    "have \(prettyCollectionType(actualValue)) with count \(stringify(expectedValue))",
                    actual: "\(actualValue.count)"
                )
                .appended(details: "Actual Value: \(stringify(actualValue))")

            let result = expectedValue == actualValue.count
            return MatcherResult(bool: result, message: message)
        } else {
            return MatcherResult(status: .fail, message: .fail(""))
        }
    }
}

/// A Nimble matcher that succeeds when the actual collection's count equals
/// the expected value
public func haveCount(_ expectedValue: Int) -> Matcher<NMBCollection> {
    return Matcher { actualExpression in
        if let actualValue = try actualExpression.evaluate() {
            let message = ExpectationMessage
                .expectedCustomValueTo(
                    "have \(prettyCollectionType(actualValue)) with count \(stringify(expectedValue))",
                    actual: "\(actualValue.count). Actual Value: \(stringify(actualValue))"
                )

            let result = expectedValue == actualValue.count
            return MatcherResult(bool: result, message: message)
        } else {
            return MatcherResult(status: .fail, message: .fail(""))
        }
    }
}

#if canImport(Darwin)
import Foundation

extension NMBMatcher {
    @objc public class func haveCountMatcher(_ expected: NSNumber) -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let location = actualExpression.location
            let actualValue = try actualExpression.evaluate()
            if let value = actualValue as? NMBCollection {
                let expr = Expression(expression: ({ value as NMBCollection}), location: location)
                return try haveCount(expected.intValue).satisfies(expr).toObjectiveC()
            }

            let message: ExpectationMessage
            if let actualValue = actualValue {
                message = ExpectationMessage.expectedCustomValueTo(
                    "get type of NSArray, NSSet, NSDictionary, or NSHashTable",
                    actual: "\(String(describing: type(of: actualValue)))"
                )
            } else {
                message = ExpectationMessage
                    .expectedActualValueTo("have a collection with count \(stringify(expected.intValue))")
                    .appendedBeNilHint()
            }
            return NMBMatcherResult(status: .fail, message: message.toObjectiveC())
        }
    }
}
#endif
