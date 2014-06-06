import Foundation

struct _BeCloseTo: Matcher {
    let expectedValue: Float
    let delta: Float

    func matches(actualExpression: () -> Float) -> (pass: Bool, messagePostfix: String)  {
        let message = "be close to <\(expectedValue)> (within \(delta))"
        let actualValue = actualExpression()
        return (abs(actualValue - expectedValue) < delta, message)
    }
}

func beCloseTo(expectedValue: Float, within delta: Float = 0.01) -> PartialMatcher<Float, _BeCloseTo> {
    return PartialMatcher(matcher: _BeCloseTo(expectedValue: expectedValue, delta: delta))
}
