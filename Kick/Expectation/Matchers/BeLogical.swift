import Foundation

struct _BeLogicalMatcher : BasicMatcher {
    let expectedValue: LogicValue
    let stringValue: String

    func matches(actualExpression: Expression<LogicValue>, failureMessage: FailureMessage) -> Bool {
        failureMessage.postfixMessage = "be \(stringValue)"
        return actualExpression.evaluate().getLogicValue() == expectedValue.getLogicValue()
    }
}

func beTruthy() -> _BeLogicalMatcher {
    return _BeLogicalMatcher(expectedValue: true, stringValue: "truthy")
}

func beFalsy() -> _BeLogicalMatcher {
    return _BeLogicalMatcher(expectedValue: false, stringValue: "falsy")
}
