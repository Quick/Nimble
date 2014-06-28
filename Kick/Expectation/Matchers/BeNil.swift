import Foundation

func beNil() -> FuncMatcherWrapper<Any?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be nil"
        let actualValue = actualExpression.evaluate()
        return !actualValue.getLogicValue()
    }
}

func beNil() -> FuncMatcherWrapper<NilType> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be nil"
        return true
    }
}
