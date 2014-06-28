import Foundation

func _doubleAsString(value: Double) -> String {
    var args = VaListBuilder()
    args.append(value)
    return NSString(format: "%.4f", arguments: args.va_list())
}

func _isCloseTo(actualValue: Double, expectedValue: Double, delta: Double, failureMessage: FailureMessage) -> Bool {
    failureMessage.actualValue = "<\(_doubleAsString(actualValue))>"
    failureMessage.postfixMessage = "be close to <\(_doubleAsString(expectedValue))> (within \(_doubleAsString(delta)))"
    return abs(actualValue - expectedValue) < delta
}

func beCloseTo(expectedValue: Double, within delta: Double = 0.0001) -> FuncMatcherWrapper<Double> {
    return MatcherFunc { actualExpression, failureMessage in
        return _isCloseTo(actualExpression.evaluate(), expectedValue, delta, failureMessage)
    }
}

func beCloseTo(expectedValue: KICDoubleConvertible, within delta: Double = 0.0001) -> FuncMatcherWrapper<KICDoubleConvertible> {
    return MatcherFunc { actualExpression, failureMessage in
        return _isCloseTo(actualExpression.evaluate().doubleValue, expectedValue.doubleValue, delta, failureMessage)
    }
}

func ==(lhs: Expectation<Double>, rhs: Double) -> Bool {
    lhs.to(beCloseTo(rhs))
    return true
}
