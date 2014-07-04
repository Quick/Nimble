import Foundation

func _isCloseTo(actualValue: Double?, expectedValue: Double, delta: Double, failureMessage: FailureMessage) -> Bool {
    failureMessage.postfixMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
    if actualValue {
        failureMessage.actualValue = "<\(stringify(actualValue!))>"
    } else {
        failureMessage.actualValue = "<nil>"
    }
    return actualValue && abs(actualValue! - expectedValue) < delta
}

func beCloseTo(expectedValue: Double, within delta: Double = 0.0001) -> MatcherFunc<Double> {
    return MatcherFunc { actualExpression, failureMessage in
        return _isCloseTo(actualExpression.evaluate(), expectedValue, delta, failureMessage)
    }
}

func beCloseTo(expectedValue: KICDoubleConvertible, within delta: Double = 0.0001) -> MatcherFunc<KICDoubleConvertible?> {
    return MatcherFunc { actualExpression, failureMessage in
        return _isCloseTo(actualExpression.evaluate()?.doubleValue, expectedValue.doubleValue, delta, failureMessage)
    }
}

class KICObjCBeCloseToMatcher : KICObjCMatcher {
    var _expected: NSNumber
    init(expected: NSNumber, within: CDouble) {
        self._expected = expected
        super.init(matcher: { actualExpression, failureMessage, location in
            let actualBlock: () -> KICDoubleConvertible? = ({
                return actualExpression() as? KICDoubleConvertible
            })
            let expr = Expression(expression: actualBlock, location: location)
            return beCloseTo(expected, within: within).matches(expr, failureMessage: failureMessage)
        })
    }

    var within: (CDouble) -> KICObjCMatcher {
        return ({ delta in
            return KICObjCBeCloseToMatcher(expected: self._expected, within: delta)
        })
    }
}

extension KICObjCMatcher {
    class func beCloseToMatcher(expected: NSNumber, within: CDouble) -> KICObjCBeCloseToMatcher {
        return KICObjCBeCloseToMatcher(expected: expected, within: within)
    }
}
