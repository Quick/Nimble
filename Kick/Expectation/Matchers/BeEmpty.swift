import Foundation

func beEmpty<S: Sequence>() -> MatcherFunc<S> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actualSeq = actualExpression.evaluate()
        var generator = actualSeq.generate()
        return !generator.next()
    }
}
