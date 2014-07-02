import Foundation

func _isCloseTo(actualValue: Double, expectedValue: Double, delta: Double, failureMessage: FailureMessage) -> Bool {
    failureMessage.actualValue = "<\(stringify(actualValue))>"
    failureMessage.postfixMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
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
