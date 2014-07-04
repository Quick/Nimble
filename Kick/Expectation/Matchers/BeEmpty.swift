import Foundation

func beEmpty<S: Sequence>() -> MatcherFunc<S?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actualSeq = actualExpression.evaluate()
        if !actualSeq {
            return true
        }
        var generator = actualSeq!.generate()
        return !generator.next()
    }
}

func beEmpty() -> MatcherFunc<NSString?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actualString = actualExpression.evaluate()
        return actualString == nil || actualString!.length == 0
    }
}

func beEmpty() -> MatcherFunc<KICCollection> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actual = actualExpression.evaluate()
        return actual.count == 0
    }
}

extension KICObjCMatcher {
    class func beEmptyMatcher() -> KICObjCMatcher {
        return KICObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as KICCollection })
            let expr = Expression(expression: block, location: location)
            return beEmpty().matches(expr, failureMessage: failureMessage)
        }
    }
}
