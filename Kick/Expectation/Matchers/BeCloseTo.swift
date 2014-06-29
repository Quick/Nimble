import Foundation

func _isCloseTo(actualValue: Double, expectedValue: Double, delta: Double, failureMessage: FailureMessage) -> Bool {
    failureMessage.actualValue = "<\(_doubleAsString(actualValue))>"
    failureMessage.postfixMessage = "be close to <\(_doubleAsString(expectedValue))> (within \(_doubleAsString(delta)))"
    return abs(actualValue - expectedValue) < delta
}

func beCloseTo(expectedValue: Double, within delta: Double = 0.0001) -> MatcherFunc<Double> {
    return MatcherFunc { actualExpression, failureMessage in
        return _isCloseTo(actualExpression.evaluate(), expectedValue, delta, failureMessage)
    }
}

func beCloseTo(expectedValue: KICDoubleConvertible, within delta: Double = 0.0001) -> MatcherFunc<KICDoubleConvertible> {
    return MatcherFunc { actualExpression, failureMessage in
        return _isCloseTo(actualExpression.evaluate().doubleValue, expectedValue.doubleValue, delta, failureMessage)
    }
}
