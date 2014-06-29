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
