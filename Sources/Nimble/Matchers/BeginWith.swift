import Foundation

/// A Nimble matcher that succeeds when the actual sequence's first element
/// is equal to the expected value.
public func beginWith<S: Sequence, T: Equatable>(_ startingElement: T) -> Predicate<S>
    where S.Iterator.Element == T {
    return .simple("begin with <\(startingElement)>") { actualExpression in
        guard let actualValue = try actualExpression.evaluate() else { return .fail }
        var actualGenerator = actualValue.makeIterator()
        return PredicateStatus(bool: actualGenerator.next() == startingElement)
    }
}

/// A Nimble matcher that succeeds when the actual collection's first element
/// is equal to the expected object.
public func beginWith(_ startingElement: Any) -> Predicate<NMBOrderedCollection> {
    return .simple("begin with <\(startingElement)>") { actualExpression in
        guard let collection = try actualExpression.evaluate() else { return .fail }
        guard let first = collection.first else { return .doesNotMatch }
        #if os(Linux)
            guard let collectionValue = first as? NSObject else { return .fail }
        #else
            let collectionValue = first as AnyObject
        #endif
        return PredicateStatus(bool: collectionValue.isEqual(startingElement))
    }
}

/// A Nimble matcher that succeeds when the actual string contains expected substring
/// where the expected substring's location is zero.
public func beginWith(_ startingSubstring: String) -> Predicate<String> {
    return .simple("begin with <\(startingSubstring)>") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }
        let range = actual.range(of: startingSubstring)
        return PredicateStatus(bool: range?.lowerBound == actual.startIndex)
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func beginWithMatcher(_ expected: Any) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let actual = try! actualExpression.evaluate()
            if (actual as? String) != nil {
                let expr = actualExpression.cast { $0 as? String }
                return try! beginWith(expected as! String).matches(expr, failureMessage: failureMessage)
            } else {
                let expr = actualExpression.cast { $0 as? NMBOrderedCollection }
                return try! beginWith(expected).matches(expr, failureMessage: failureMessage)
            }
        }
    }
}
#endif
