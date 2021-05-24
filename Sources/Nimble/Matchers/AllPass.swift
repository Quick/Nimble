public func allPass<S: Sequence>(
    _ passFunc: @escaping (S.Element) throws -> Bool
) -> Predicate<S> {
    let matcher = Predicate<S.Element>.define("pass a condition") { actualExpression, message in
        guard let actual = try actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: message)
        }
        return PredicateResult(bool: try passFunc(actual), message: message)
    }
    return createPredicate(matcher)
}

public func allPass<S: Sequence>(
    _ passName: String,
    _ passFunc: @escaping (S.Element) throws -> Bool
) -> Predicate<S> {
    let matcher = Predicate<S.Element>.define(passName) { actualExpression, message in
        guard let actual = try actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: message)
        }
        return PredicateResult(bool: try passFunc(actual), message: message)
    }
    return createPredicate(matcher)
}

public func allPass<S: Sequence>(_ elementPredicate: Predicate<S.Element>) -> Predicate<S> {
    return createPredicate(elementPredicate)
}

private func createPredicate<S: Sequence>(_ elementMatcher: Predicate<S.Element>) -> Predicate<S> {
    return Predicate { actualExpression in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: .appends(.expectedTo("all pass"), " (use beNil() to match nils)")
            )
        }

        var failure: ExpectationMessage = .expectedTo("all pass")
        for currentElement in actualValue {
            let exp = Expression(
                expression: { currentElement },
                location: actualExpression.location
            )
            let predicateResult = try elementMatcher.satisfies(exp)
            if predicateResult.status == .matches {
                failure = predicateResult.message.prepended(expectation: "all ")
            } else {
                failure = predicateResult.message
                    .replacedExpectation({ .expectedTo($0.expectedMessage) })
                    .wrappedExpectation(
                        before: "all ",
                        after: ", but failed first at element <\(stringify(currentElement))>"
                            + " in <\(stringify(actualValue))>"
                )
                return PredicateResult(status: .doesNotMatch, message: failure)
            }
        }
        failure = failure.replacedExpectation({ expectation in
            return .expectedTo(expectation.expectedMessage)
        })
        return PredicateResult(status: .matches, message: failure)
    }
}

#if canImport(Darwin)
import class Foundation.NSObject
import struct Foundation.NSFastEnumerationIterator
import protocol Foundation.NSFastEnumeration

extension NMBPredicate {
    @objc public class func allPassMatcher(_ predicate: NMBPredicate) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            let location = actualExpression.location
            let actualValue = try actualExpression.evaluate()
            var nsObjects = [NSObject]()

            var collectionIsUsable = true
            if let value = actualValue as? NSFastEnumeration {
                var generator = NSFastEnumerationIterator(value)
                while let obj = generator.next() {
                    if let nsObject = obj as? NSObject {
                        nsObjects.append(nsObject)
                    } else {
                        collectionIsUsable = false
                        break
                    }
                }
            } else {
                collectionIsUsable = false
            }

            if !collectionIsUsable {
                return NMBPredicateResult(
                    status: NMBPredicateStatus.fail,
                    message: NMBExpectationMessage(
                        // swiftlint:disable:next line_length
                        fail: "allPass can only be used with types which implement NSFastEnumeration (NSArray, NSSet, ...), and whose elements subclass NSObject, got <\(actualValue?.description ?? "nil")>"
                    )
                )
            }

            let expr = Expression(expression: ({ nsObjects }), location: location)
            let pred: Predicate<[NSObject]> = createPredicate(Predicate { expr in
                return predicate.satisfies(({ try expr.evaluate() }), location: expr.location).toSwift()
            })
            return try pred.satisfies(expr).toObjectiveC()
        }
    }
}
#endif
