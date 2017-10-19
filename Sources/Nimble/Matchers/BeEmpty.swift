import Foundation

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty<S: Sequence>() -> Predicate<S> {
    return .simple("be empty") { actualExpression in
        let actualSeq = try actualExpression.evaluate()
        if actualSeq == nil {
            return .fail
        }
        var generator = actualSeq!.makeIterator()
        return PredicateStatus(bool: generator.next() == nil)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<String> {
    return .simple("be empty") { actualExpression in
        let actualString = try actualExpression.evaluate()
        return PredicateStatus(bool: actualString?.count == 0)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For NSString instances, it is an empty string.
public func beEmpty() -> Predicate<NSString> {
    return .simple("be empty") { actualExpression in
        let actualString = try actualExpression.evaluate()
        return PredicateStatus(bool: actualString?.length == 0)
    }
}

// Without specific overrides, beEmpty() is ambiguous for NSDictionary, NSArray,
// etc, since they conform to Sequence as well as NMBCollection.

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<NSDictionary> {
	return .simple("be empty") { actualExpression in
		let actualDictionary = try actualExpression.evaluate()
        return PredicateStatus(bool: actualDictionary?.count == 0)
	}
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<NSArray> {
	return .simple("be empty") { actualExpression in
		let actualArray = try actualExpression.evaluate()
        return PredicateStatus(bool: actualArray?.count == 0)
	}
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<NMBCollection> {
    return .simple("be empty") { actualExpression in
        let actual = try actualExpression.evaluate()
        return PredicateStatus(bool: actual?.count == 0)
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func beEmptyMatcher() -> NMBPredicate {
        return NMBPredicate { actualExpression in
            let location = actualExpression.location
            let actualValue = try! actualExpression.evaluate()

            if let value = actualValue as? NMBCollection {
                let expr = Expression(expression: ({ value as NMBCollection }), location: location)
                return try! beEmpty().satisfies(expr).toObjectiveC()
            } else if let value = actualValue as? NSString {
                let expr = Expression(expression: ({ value as String }), location: location)
                return try! beEmpty().satisfies(expr).toObjectiveC()
            } else if let actualValue = actualValue {
                // swiftlint:disable:next line_length
                let badTypeErrorMsg = "be empty (only works for NSArrays, NSSets, NSIndexSets, NSDictionaries, NSHashTables, and NSStrings)"
                return NMBPredicateResult(
                    status: .fail,
                    message: NMBExpectationMessage(
                        expectedActualValueTo: badTypeErrorMsg,
                        customActualValue: "\(String(describing: type(of: actualValue))) type"
                    )
                )
            }
            return NMBPredicateResult(
                status: .fail,
                message: NMBExpectationMessage(expectedActualValueTo: "be empty").appendedBeNilHint()
            )
        }
    }
}
#endif
