import Foundation

struct _BeNilMatcher: BasicMatcher {
    func matches(actualExpression: Expression<Any?>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (!actualValue.getLogicValue(), "be nil")
    }
}

struct _BeNilNoTypeMatcher: BasicMatcher {
    func matches(actualExpression: Expression<NilType>) -> (pass: Bool, postfix: String)  {
        return (true, "be nil")
    }
}

func beNil() -> _BeNilMatcher {
    return _BeNilMatcher()
}

func beNil() -> _BeNilNoTypeMatcher {
    return _BeNilNoTypeMatcher()
}
