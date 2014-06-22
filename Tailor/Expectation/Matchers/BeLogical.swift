import Foundation

struct _BeLogicalMatcher : BasicMatcher {
    let expectedValue: LogicValue
    let stringValue: String

    func matches(actualExpression: Expression<LogicValue>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (actualValue.getLogicValue() == expectedValue.getLogicValue(), "be \(stringValue)")
    }
}

func beTruthy() -> _BeLogicalMatcher {
    return _BeLogicalMatcher(expectedValue: true, stringValue: "truthy")
}

func beFalsy() -> _BeLogicalMatcher {
    return _BeLogicalMatcher(expectedValue: false, stringValue: "falsy")
}
