import Foundation

func beNil() -> FuncMatcherWrapper<Any?> {
    return DefineMatcher { actualExpression in
        let actualValue = actualExpression.evaluate()
        return (!actualValue.getLogicValue(), "be nil")
    }
}

func beNil() -> FuncMatcherWrapper<NilType> {
    return DefineMatcher { actualExpression in
        return (true, "be nil")
    }
}
