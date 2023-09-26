import Foundation

/// A Nimble matcher that succeeds when the actual sequence's last element
/// is equal to the expected value.
public func endWith<S: Sequence>(_ endingElement: S.Element) -> Matcher<S> where S.Element: Equatable {
    return Matcher.simple("end with <\(endingElement)>") { actualExpression in
        guard let actualValue = try actualExpression.evaluate() else { return .fail }

        var actualGenerator = actualValue.makeIterator()
        var lastItem: S.Element?
        var item: S.Element?
        repeat {
            lastItem = item
            item = actualGenerator.next()
        } while(item != nil)

        return MatcherStatus(bool: lastItem == endingElement)
    }
}

/// A Nimble matcher that succeeds when the actual collection's last element
/// is equal to the expected object.
public func endWith(_ endingElement: Any) -> Matcher<NMBOrderedCollection> {
    return Matcher.simple("end with <\(endingElement)>") { actualExpression in
        guard let collection = try actualExpression.evaluate() else { return .fail }

        guard collection.count > 0 else { return MatcherStatus(bool: false) }
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let collectionValue = collection.object(at: collection.count - 1) as AnyObject
        #else
            guard let collectionValue = collection.object(at: collection.count - 1) as? NSObject else {
                return .fail
            }
        #endif

        return MatcherStatus(bool: collectionValue.isEqual(endingElement))
    }
}

/// A Nimble matcher that succeeds when the actual string contains the expected substring
/// where the expected substring's location is the actual string's length minus the
/// expected substring's length.
public func endWith(_ endingSubstring: String) -> Matcher<String> {
    return Matcher.simple("end with <\(endingSubstring)>") { actualExpression in
        guard let collection = try actualExpression.evaluate() else { return .fail }

        return MatcherStatus(bool: collection.hasSuffix(endingSubstring))
    }
}

#if canImport(Darwin)
extension NMBMatcher {
    @objc public class func endWithMatcher(_ expected: Any) -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let actual = try actualExpression.evaluate()
            if actual is String {
                let expr = actualExpression.cast { $0 as? String }
                // swiftlint:disable:next force_cast
                return try endWith(expected as! String).satisfies(expr).toObjectiveC()
            } else {
                let expr = actualExpression.cast { $0 as? NMBOrderedCollection }
                return try endWith(expected).satisfies(expr).toObjectiveC()
            }
        }
    }
}
#endif
