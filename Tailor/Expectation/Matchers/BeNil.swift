import Foundation

struct _BeNilMatcher: BasicMatcher {
    func matches(actualExpression: Expression<Any?>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (!actualValue.getLogicValue(), "be nil")
    }
}

func beNil() -> _BeNilMatcher {
    return _BeNilMatcher()
}
