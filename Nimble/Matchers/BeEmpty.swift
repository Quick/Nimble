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

func beEmpty() -> MatcherFunc<NMBCollection?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actual = actualExpression.evaluate()
        return !actual || actual!.count == 0
    }
}

extension NMBObjCMatcher {
    class func beEmptyMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ actualBlock() as? NMBCollection })
            let expr = Expression(expression: block, location: location)
            return beEmpty().matches(expr, failureMessage: failureMessage)
        }
    }
}
