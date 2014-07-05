import Foundation

func beNil<T>() -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be nil"
        let actualValue = actualExpression.evaluate()
        return !actualValue.getLogicValue()
    }
}

func beNil() -> MatcherFunc<NilType> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be nil"
        return true
    }
}

extension KICObjCMatcher {
    class func beNilMatcher() -> KICObjCMatcher {
        return KICObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as NSObject? })
            let expr = Expression(expression: block, location: location)
            return beNil().matches(expr, failureMessage: failureMessage)
        }
    }
}
