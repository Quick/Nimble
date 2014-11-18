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
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage, location in
            return beAnInstanceOf(expected).matches(actualExpression, failureMessage: failureMessage)
        }
    }
}
