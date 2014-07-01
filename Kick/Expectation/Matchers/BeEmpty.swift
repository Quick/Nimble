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
