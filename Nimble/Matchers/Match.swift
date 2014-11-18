import Foundation

public func match(expectedValue:String?) -> NonNilMatcherFunc<String> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "match <\(stringify(expectedValue))>"
        
        if let actual = actualExpression.evaluate() {
            if let regexp = expectedValue {
                return actual.rangeOfString(regexp, options: .RegularExpressionSearch) != nil
            }
        }

        return false
    }
}

extension NMBObjCMatcher {
    public class func matchMatcher(expected: NSString) -> NMBMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage, location in
            let actual = actualExpression.cast { $0 as? String }
            return match(expected).matches(actual, failureMessage: failureMessage)
        }
    }
}

