import Foundation

struct _BeLogicalMatcher: BasicMatcher {
    let expectedValue: LogicValue
    let stringValue: String

    func matches(actualExpression: Expression<LogicValue>, failureMessage: FailureMessage) -> Bool {
        failureMessage.postfixMessage = "be \(stringValue)"
        return actualExpression.evaluate().getLogicValue() == expectedValue.getLogicValue()
    }
}

struct _BeOptionalBoolMatcher: BasicMatcher {
    let expectedValue: LogicValue
    let stringValue: String

    func matches(actualExpression: Expression<Bool?>, failureMessage: FailureMessage) -> Bool {
        failureMessage.postfixMessage = "be \(stringValue)"
        let actual = actualExpression.evaluate()
        return (actual && actual!.getLogicValue()) == expectedValue.getLogicValue()
    }
}

func beTruthy() -> _BeLogicalMatcher {
    return _BeLogicalMatcher(expectedValue: true, stringValue: "truthy")
}

func beFalsy() -> _BeLogicalMatcher {
    return _BeLogicalMatcher(expectedValue: false, stringValue: "falsy")
}

func beTruthy() -> _BeOptionalBoolMatcher {
    return _BeOptionalBoolMatcher(expectedValue: true, stringValue: "truthy")
}

func beFalsy() -> _BeOptionalBoolMatcher {
    return _BeOptionalBoolMatcher(expectedValue: false, stringValue: "falsy")
}
