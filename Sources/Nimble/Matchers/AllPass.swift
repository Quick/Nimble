import Foundation

public func allPass<T, U>
    (_ passFunc: @escaping (T?) throws -> Bool) -> Predicate<U>
    where U: Sequence, T == U.Iterator.Element {
        let matcher = Predicate<T>.fromBool { actualExpression, failureMessage in
            failureMessage.postfixMessage = "pass a condition"
            return try passFunc(try actualExpression.evaluate())
        }
        return createPredicate(matcher)
}

public func allPass<T, U>
    (_ passName: String, _ passFunc: @escaping (T?) throws -> Bool) -> Predicate<U>
    where U: Sequence, T == U.Iterator.Element {
        let matcher = Predicate<T>.fromBool { actualExpression, failureMessage in
            failureMessage.postfixMessage = passName
            return try passFunc(try actualExpression.evaluate())
        }
        return createPredicate(matcher)
}

public func allPass<S, M>(_ elementMatcher: M) -> Predicate<S>
    where S: Sequence, M: Matcher, S.Iterator.Element == M.ValueType {
        return createPredicate(elementMatcher.predicate)
}

private func createPredicate<S>(_ elementMatcher: Predicate<S.Iterator.Element>) -> Predicate<S>
    where S: Sequence {
        return Predicate<S>.fromBool { actualExpression, failureMessage, expectMatch in
            failureMessage.actualValue = nil
            guard let actualValue = try actualExpression.evaluate() else {
                failureMessage.postfixMessage = "all pass (use beNil() to match nils)"
                return false
            }
            for currentElement in actualValue {
                let exp = Expression(
                    expression: {currentElement}, location: actualExpression.location)
                if try !elementMatcher.matches(exp, failureMessage: failureMessage) {
                    if expectMatch {
                        failureMessage.postfixMessage =
                            "all \(failureMessage.postfixMessage),"
                            + " but failed first at element <\(stringify(currentElement))>"
                            + " in <\(stringify(actualValue))>"
                    } else {
                        failureMessage.postfixMessage = "all \(failureMessage.postfixMessage)"
                    }
                    return !expectMatch
                }
            }

            failureMessage.postfixMessage = "all \(failureMessage.postfixMessage)"
            return expectMatch
        }.requireNonNil
}

#if _runtime(_ObjC)
extension NMBObjCMatcher {
    public class func allPassMatcher(_ matcher: NMBObjCMatcher) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let location = actualExpression.location
            let actualValue = try! actualExpression.evaluate()
            var nsObjects = [NSObject]()

            var collectionIsUsable = true
            if let value = actualValue as? NSFastEnumeration {
                let generator = NSFastEnumerationIterator(value)
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
                failureMessage.postfixMessage =
                  "allPass only works with NSFastEnumeration (NSArray, NSSet, ...) of NSObjects"
                failureMessage.expected = ""
                failureMessage.to = ""
                return false
            }

            let expr = Expression(expression: ({ nsObjects }), location: location)
            let pred: Predicate<[NSObject]> = createPredicate(Predicate.fromBool { expr, failureMessage, expectMatch in
                if expectMatch {
                    return matcher.matches({ try! expr.evaluate() }, failureMessage: failureMessage, location: expr.location)
                } else {
                    return matcher.doesNotMatch({ try! expr.evaluate() }, failureMessage: failureMessage, location: expr.location)
                }
            })
            return try! pred.matches(expr, failureMessage: failureMessage)
        }
    }
}
#endif
