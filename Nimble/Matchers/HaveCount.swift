import Foundation

public func haveCount<T: Equatable>(expectedValue: Int) -> MatcherFunc<[T]> {
    return MatcherFunc { actualExpression, failureMessage in
        if let actualValue = try actualExpression.evaluate() {
            failureMessage.postfixMessage = "have \(actualValue) with count \(actualValue.count)"
            let result = expectedValue == actualValue.count
            failureMessage.actualValue = "\(expectedValue)"
            return result
        } else {
            return false
        }
    }
}

extension NMBObjCMatcher {
    public class func haveCountMatcher(expected: NSNumber) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let expr = actualExpression.cast({ $0 as? [NSObject] })
            return try! haveCount(expected.integerValue).matches(expr, failureMessage: failureMessage)
        }
    }
}
