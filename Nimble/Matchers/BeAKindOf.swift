import Foundation

public func beAKindOf(expectedClass: AnyClass) -> NonNilMatcherFunc<NSObject> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        let instance = actualExpression.evaluate()
        if let validInstance = instance {
            failureMessage.actualValue = "<\(NSStringFromClass(validInstance.dynamicType)) instance>"
        } else {
            failureMessage.actualValue = "<nil>"
        }
        failureMessage.postfixMessage = "be a kind of \(NSStringFromClass(expectedClass))"
        return instance != nil && instance!.isKindOfClass(expectedClass)
    }
}

extension NMBObjCMatcher {
    public class func beAKindOfMatcher(expected: AnyClass) -> NMBMatcher {
        return NMBObjCMatcher { actualExpression, failureMessage, location in
            let expr = Expression(expression: actualExpression, location: location)
            let matcher = NonNilMatcherWrapper(NonNilBasicMatcherWrapper(beAKindOf(expected)))
            return matcher.matches(expr, failureMessage: failureMessage)
        }
    }
}
