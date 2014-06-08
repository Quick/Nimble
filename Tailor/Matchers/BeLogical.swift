import Foundation

struct _BeLogically : Matcher {
    let expectedValue: LogicValue
    let stringValue: String

    func matches(actualExpression: Expression<LogicValue>) -> (pass: Bool, messagePostfix: String)  {
        let actualValue = actualExpression.evaluate()
        return (actualValue.getLogicValue() == expectedValue.getLogicValue(), "be \(stringValue)")
    }
}

func beTruthy() -> _BeLogically {
    return _BeLogically(expectedValue: true, stringValue: "truthy")
}

func beFalsy() -> _BeLogically {
    return _BeLogically(expectedValue: false, stringValue: "falsy")
}
