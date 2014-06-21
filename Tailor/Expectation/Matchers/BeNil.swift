import Foundation

struct _BeNil: Matcher {
    func matches(actualExpression: Expression<Any?>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (!actualValue.getLogicValue(), "be nil")
    }
}

func beNil() -> _BeNil {
    return _BeNil()
}
