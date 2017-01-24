import Foundation

/// A Nimble matcher that succeeds when the actual value is an _exact_ instance of the given class.
public func beAnInstanceOf<T>(_ expectedType: T.Type) -> Predicate<Any> {
    return Predicate {actualExpression, failureMessage -> Bool in
        failureMessage.postfixMessage = "be an instance of \(String(describing: expectedType))"
        let instance = try actualExpression.evaluate()
        guard let validInstance = instance else {
            failureMessage.actualValue = "<nil>"
            return false
        }

        failureMessage.actualValue = "<\(String(describing: type(of: validInstance))) instance>"

        if type(of: validInstance) == expectedType {
            return true
        }

        return false
    }.requireNonNil
}

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
/// @see beAKindOf if you want to match against subclasses
public func beAnInstanceOf(_ expectedClass: AnyClass) -> Predicate<NSObject> {
    return Predicate { actualExpression, failureMessage -> Bool in
        let instance = try actualExpression.evaluate()
        if let validInstance = instance {
            failureMessage.actualValue = "<\(String(describing: type(of: validInstance))) instance>"
        } else {
            failureMessage.actualValue = "<nil>"
        }
        failureMessage.postfixMessage = "be an instance of \(String(describing: expectedClass))"
#if _runtime(_ObjC)
        return instance != nil && instance!.isMember(of: expectedClass)
#else
        return instance != nil && type(of: instance!) == expectedClass
#endif
    }.requireNonNil
}

#if _runtime(_ObjC)
extension NMBObjCMatcher {
    public class func beAnInstanceOfMatcher(_ expected: AnyClass) -> NMBMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            return try! beAnInstanceOf(expected).matches(actualExpression, failureMessage: failureMessage)
        }
    }
}
#endif
