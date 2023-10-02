public func allPass<S: Sequence>(
    _ passFunc: @escaping (S.Element) throws -> Bool
) -> Matcher<S> {
    let matcher = Matcher<S.Element>.define("pass a condition") { actualExpression, message in
        guard let actual = try actualExpression.evaluate() else {
            return MatcherResult(status: .fail, message: message)
        }
        return MatcherResult(bool: try passFunc(actual), message: message)
    }
    return createMatcher(matcher)
}

public func allPass<S: Sequence>(
    _ passName: String,
    _ passFunc: @escaping (S.Element) throws -> Bool
) -> Matcher<S> {
    let matcher = Matcher<S.Element>.define(passName) { actualExpression, message in
        guard let actual = try actualExpression.evaluate() else {
            return MatcherResult(status: .fail, message: message)
        }
        return MatcherResult(bool: try passFunc(actual), message: message)
    }
    return createMatcher(matcher)
}

public func allPass<S: Sequence>(_ elementMatcher: Matcher<S.Element>) -> Matcher<S> {
    return createMatcher(elementMatcher)
}

private func createMatcher<S: Sequence>(_ elementMatcher: Matcher<S.Element>) -> Matcher<S> {
    return Matcher { actualExpression in
        guard let actualValue = try actualExpression.evaluate() else {
            return MatcherResult(
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
            let matcherResult = try elementMatcher.satisfies(exp)
            if matcherResult.status == .matches {
                failure = matcherResult.message.prepended(expectation: "all ")
            } else {
                failure = matcherResult.message
                    .replacedExpectation({ .expectedTo($0.expectedMessage) })
                    .wrappedExpectation(
                        before: "all ",
                        after: ", but failed first at element <\(stringify(currentElement))>"
                            + " in <\(stringify(actualValue))>"
                )
                return MatcherResult(status: .doesNotMatch, message: failure)
            }
        }
        failure = failure.replacedExpectation({ expectation in
            return .expectedTo(expectation.expectedMessage)
        })
        return MatcherResult(status: .matches, message: failure)
    }
}

#if canImport(Darwin)
import class Foundation.NSObject
import struct Foundation.NSFastEnumerationIterator
import protocol Foundation.NSFastEnumeration

extension NMBMatcher {
    @objc public class func allPassMatcher(_ matcher: NMBMatcher) -> NMBMatcher {
        return NMBMatcher { actualExpression in
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
                return NMBMatcherResult(
                    status: NMBMatcherStatus.fail,
                    message: NMBExpectationMessage(
                        // swiftlint:disable:next line_length
                        fail: "allPass can only be used with types which implement NSFastEnumeration (NSArray, NSSet, ...), and whose elements subclass NSObject, got <\(actualValue?.description ?? "nil")>"
                    )
                )
            }

            let expr = Expression(expression: ({ nsObjects }), location: location)
            let pred: Matcher<[NSObject]> = createMatcher(Matcher { expr in
                return matcher.satisfies(({ try expr.evaluate() }), location: expr.location).toSwift()
            })
            return try pred.satisfies(expr).toObjectiveC()
        }
    }
}
#endif
