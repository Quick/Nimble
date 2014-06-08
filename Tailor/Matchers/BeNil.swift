import Foundation

struct _BeNil: Matcher {
    func matches(actualExpression: Expression<Any?>) -> (pass: Bool, messagePostfix: String)  {
        let actualValue = actualExpression.evaluateIfNeeded()
        return (!actualValue.getLogicValue(), "be nil")
    }
}

func beNil() -> _BeNil {
    return _BeNil()
}
