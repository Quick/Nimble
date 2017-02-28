import Foundation

/// A Nimble matcher that succeeds when the actual value is an _exact_ instance of the given class.
public func beAnInstanceOf<T>(_ expectedType: T.Type) -> Predicate<Any> {
    let errorMessage = "be an instance of \(String(describing: expectedType))"
    return Predicate.define { actualExpression -> (Satisfiability, ExpectationMessage) in
        let instance = try actualExpression.evaluate()
        guard let validInstance = instance else {
            return (.DoesNotMatch, .ExpectedActualValueTo(errorMessage))
        }

        let actualString = "<\(String(describing: type(of: validInstance))) instance>"

        return (
            Satisfiability(bool: type(of: validInstance) == expectedType),
            .ExpectedValueTo(errorMessage, actualString)
        )
    }
}

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
/// @see beAKindOf if you want to match against subclasses
public func beAnInstanceOf(_ expectedClass: AnyClass) -> Predicate<NSObject> {
    let errorMessage = "be an instance of \(String(describing: expectedClass))"
    return Predicate.define { actualExpression -> (Satisfiability, ExpectationMessage) in
        let instance = try actualExpression.evaluate()
        let actualString: String
        if let validInstance = instance {
            actualString = "<\(String(describing: type(of: validInstance))) instance>"
        } else {
            actualString = "<nil>"
        }
#if _runtime(_ObjC)
    let matches = instance != nil && instance!.isMember(of: expectedClass)
#else
    let matches = instance != nil && type(of: instance!) == expectedClass
#endif
        return (Satisfiability(bool: matches), .ExpectedValueTo(errorMessage, actualString))
    }
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
