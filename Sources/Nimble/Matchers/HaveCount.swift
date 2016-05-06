import Foundation

/// A Nimble matcher that succeeds when the actual Collection's count equals
/// the expected value
public func haveCount<T: Collection>(_ expectedValue: T.IndexDistance) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        if let actualValue = try actualExpression.evaluate() {
            failureMessage.postfixMessage = "have \(stringify(actualValue)) with count \(stringify(expectedValue))"
            let result = expectedValue == actualValue.count
            failureMessage.actualValue = "\(actualValue.count)"
            return result
        } else {
            return false
        }
    }
}

/// A Nimble matcher that succeeds when the actual collection's count equals
/// the expected value
public func haveCount(_ expectedValue: Int) -> MatcherFunc<NMBCollection> {
    return MatcherFunc { actualExpression, failureMessage in
        if let actualValue = try actualExpression.evaluate() {
            failureMessage.postfixMessage = "have \(stringify(actualValue)) with count \(stringify(expectedValue))"
            let result = expectedValue == actualValue.count
            failureMessage.actualValue = "\(actualValue.count)"
            return result
        } else {
            return false
        }
    }
}

#if _runtime(_ObjC)
extension NMBObjCMatcher {
    public class func haveCountMatcher(_ expected: NSNumber) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let location = actualExpression.location
            let actualValue = try! actualExpression.evaluate()
            if let value = actualValue as? NMBCollection {
                let expr = Expression(expression: ({ value as NMBCollection}), location: location)
                return try! haveCount(expected.intValue).matches(expr, failureMessage: failureMessage)
            } else if let actualValue = actualValue {
                failureMessage.postfixMessage = "get type of NSArray, NSSet, NSDictionary, or NSHashTable"
                failureMessage.actualValue = "\(classAsString(actualValue.dynamicType))"
            }
            return false
        }
    }
}
#endif
