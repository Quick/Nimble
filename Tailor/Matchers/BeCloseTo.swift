import Foundation

struct _BeCloseTo: MatcherWithFullMessage {
    let expectedValue: Double
    let delta: Double

    func isCloseTo(actualValue: Double, negate: Bool) -> (Bool, String) {
        var args = VaListBuilder()
        args.append(actualValue)
        args.append(negate ? "to not" : "to")
        args.append(expectedValue)
        args.append(delta)
        let message = NSString(format: "expected <%.4f> %@ be close to <%.4f> (within %.4f)", arguments: args.va_list())
        return ((abs(actualValue - expectedValue) < delta) == !negate, message)
    }

    func matches(actualExpression: Expression<Double>) -> (pass: Bool, message: String)  {
        let actualValue = actualExpression.evaluate()
        return isCloseTo(actualValue, negate: false)
    }

    func doesNotMatch(actualExpression: Expression<Double>) -> (pass: Bool, message: String)  {
        let actualValue = actualExpression.evaluate()
        return isCloseTo(actualValue, negate: true)
    }
}

func beCloseTo(expectedValue: Double, within delta: Double = 0.0001) -> _BeCloseTo {
    return _BeCloseTo(expectedValue: expectedValue, delta: delta)
}

func ==(lhs: Expectation<Double>, rhs: Double) -> Bool {
    lhs.to(beCloseTo(rhs))
    return true
}
