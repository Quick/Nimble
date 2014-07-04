import Foundation


func beIdenticalTo<T: NSObject>(expected: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        let actual = actualExpression.evaluate()
        failureMessage.actualValue = "\(_identityAsString(actual))"
        failureMessage.postfixMessage = "be identical to \(_identityAsString(expected))"
        return actual === expected
    }
}

func ===<T: NSObject>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.to(beIdenticalTo(rhs))
    return true
}
func !==<T: NSObject>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.toNot(beIdenticalTo(rhs))
    return true
}

extension KICObjCMatcher {
    class func beIdenticalToMatcher(expected: NSObject?) -> KICObjCMatcher {
        return KICObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as NSObject? })
            let expr = Expression(expression: block, location: location)
            return beIdenticalTo(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
