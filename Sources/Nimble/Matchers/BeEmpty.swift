import Foundation

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty<S: Sequence>() -> Matcher<S> {
    return Matcher.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }

        var generator = actual.makeIterator()
        return MatcherStatus(bool: generator.next() == nil)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty<S: SetAlgebra>() -> Matcher<S> {
    return Matcher.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }
        return MatcherStatus(bool: actual.isEmpty)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty<S: Sequence & SetAlgebra>() -> Matcher<S> {
    return Matcher.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }
        return MatcherStatus(bool: actual.isEmpty)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Matcher<String> {
    return Matcher.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }
        return MatcherStatus(bool: actual.isEmpty)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For NSString instances, it is an empty string.
public func beEmpty() -> Matcher<NSString> {
    return Matcher.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }
        return MatcherStatus(bool: actual.length == 0)
    }
}

// Without specific overrides, beEmpty() is ambiguous for NSDictionary, NSArray,
// etc, since they conform to Sequence as well as NMBCollection.

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Matcher<NSDictionary> {
    return Matcher.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }
        return MatcherStatus(bool: actual.count == 0)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Matcher<NSArray> {
    return Matcher.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }
        return MatcherStatus(bool: actual.count == 0)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Matcher<NMBCollection> {
    return Matcher.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }
        return MatcherStatus(bool: actual.count == 0)
    }
}

#if canImport(Darwin)
extension NMBMatcher {
    @objc public class func beEmptyMatcher() -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let location = actualExpression.location
            let actualValue = try actualExpression.evaluate()

            if let value = actualValue as? NMBCollection {
                let expr = Expression(expression: ({ value }), location: location)
                return try beEmpty().satisfies(expr).toObjectiveC()
            } else if let value = actualValue as? NSString {
                let expr = Expression(expression: ({ value }), location: location)
                return try beEmpty().satisfies(expr).toObjectiveC()
            } else if let actualValue = actualValue {
                let badTypeErrorMsg = "be empty (only works for NSArrays, NSSets, NSIndexSets, NSDictionaries, NSHashTables, and NSStrings)"
                return NMBMatcherResult(
                    status: NMBMatcherStatus.fail,
                    message: NMBExpectationMessage(
                        expectedActualValueTo: badTypeErrorMsg,
                        customActualValue: "\(String(describing: type(of: actualValue))) type"
                    )
                )
            }
            return NMBMatcherResult(
                status: NMBMatcherStatus.fail,
                message: NMBExpectationMessage(expectedActualValueTo: "be empty").appendedBeNilHint()
            )
        }
    }
}
#endif
