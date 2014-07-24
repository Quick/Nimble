import Foundation

public struct _BeLogicalMatcher: BasicMatcher {
    public let expectedValue: LogicValue
    public let stringValue: String

    public func matches(actualExpression: Expression<LogicValue>, failureMessage: FailureMessage) -> Bool {
        failureMessage.postfixMessage = "be \(stringValue)"
        return actualExpression.evaluate().getLogicValue() == expectedValue.getLogicValue()
    }
}

public struct _BeOptionalBoolMatcher: BasicMatcher {
    public let expectedValue: LogicValue
    public let stringValue: String

    public func matches(actualExpression: Expression<Bool?>, failureMessage: FailureMessage) -> Bool {
        failureMessage.postfixMessage = "be \(stringValue)"
        let actual = actualExpression.evaluate()
        return (actual && actual!.getLogicValue()) == expectedValue.getLogicValue()
    }
}

public func beTruthy() -> _BeLogicalMatcher {
    return _BeLogicalMatcher(expectedValue: true, stringValue: "truthy")
}

public func beFalsy() -> _BeLogicalMatcher {
    return _BeLogicalMatcher(expectedValue: false, stringValue: "falsy")
}

public func beTruthy() -> _BeOptionalBoolMatcher {
    return _BeOptionalBoolMatcher(expectedValue: true, stringValue: "truthy")
}

public func beFalsy() -> _BeOptionalBoolMatcher {
    return _BeOptionalBoolMatcher(expectedValue: false, stringValue: "falsy")
}

extension NMBObjCMatcher {
    public class func beTruthyMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ (actualBlock() as? NSNumber)?.boolValue })
            let expr = Expression(expression: block, location: location)
            return beTruthy().matches(expr, failureMessage: failureMessage)
        }
    }
    public class func beFalsyMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let block = ({ (actualBlock() as? NSNumber)?.boolValue })
            let expr = Expression(expression: block, location: location)
            return beFalsy().matches(expr, failureMessage: failureMessage)
        }
    }
}
