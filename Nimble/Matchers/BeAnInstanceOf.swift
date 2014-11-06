import Foundation

public func beAnInstanceOf(expectedClass: AnyClass) -> NonNilMatcherFunc<NSObject> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        let instance = actualExpression.evaluate()
        if let validInstance = instance {
            failureMessage.actualValue = "<\(NSStringFromClass(validInstance.dynamicType)) instance>"
        } else {
            failureMessage.actualValue = "<nil>"
        }
        failureMessage.postfixMessage = "be an instance of \(NSStringFromClass(expectedClass))"
        return instance != nil && instance!.isMemberOfClass(expectedClass)
    }
}

extension NMBObjCMatcher {
    public class func beAnInstanceOfMatcher(expected: AnyClass) -> NMBMatcher {
        return NMBObjCMatcher { actualExpression, failureMessage, location, shouldNotMatch in
            let expr = Expression(expression: actualExpression, location: location)
            let matcher = NonNilMatcherWrapper(NonNilBasicMatcherWrapper(beAnInstanceOf(expected)))
            if shouldNotMatch {
                return matcher.doesNotMatch(expr, failureMessage: failureMessage)
            } else {
                return matcher.matches(expr, failureMessage: failureMessage)
            }
        }
    }
}
