import Foundation

/// A Nimble matcher that succeeds when the actual sequence's first element
/// is equal to the expected value.
public func beginWith<S: Sequence>(_ startingElement: S.Element) -> Matcher<S> where S.Element: Equatable {
    return Matcher.simple("begin with <\(startingElement)>") { actualExpression in
        guard let actualValue = try actualExpression.evaluate() else { return .fail }

        var actualGenerator = actualValue.makeIterator()
        return MatcherStatus(bool: actualGenerator.next() == startingElement)
    }
}

/// A Nimble matcher that succeeds when the actual collection's first element
/// is equal to the expected object.
public func beginWith(_ startingElement: Any) -> Matcher<NMBOrderedCollection> {
    return Matcher.simple("begin with <\(startingElement)>") { actualExpression in
        guard let collection = try actualExpression.evaluate() else { return .fail }
        guard collection.count > 0 else { return .doesNotMatch }
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let collectionValue = collection.object(at: 0) as AnyObject
        #else
            guard let collectionValue = collection.object(at: 0) as? NSObject else {
                return .fail
            }
        #endif
        return MatcherStatus(bool: collectionValue.isEqual(startingElement))
    }
}

/// A Nimble matcher that succeeds when the actual string contains expected substring
/// where the expected substring's location is zero.
public func beginWith(_ startingSubstring: String) -> Matcher<String> {
    return Matcher.simple("begin with <\(startingSubstring)>") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }

        return MatcherStatus(bool: actual.hasPrefix(startingSubstring))
    }
}

#if canImport(Darwin)
extension NMBMatcher {
    @objc public class func beginWithMatcher(_ expected: Any) -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let actual = try actualExpression.evaluate()
            if actual is String {
                let expr = actualExpression.cast { $0 as? String }
                // swiftlint:disable:next force_cast
                return try beginWith(expected as! String).satisfies(expr).toObjectiveC()
            } else {
                let expr = actualExpression.cast { $0 as? NMBOrderedCollection }
                return try beginWith(expected).satisfies(expr).toObjectiveC()
            }
        }
    }
}
#endif
