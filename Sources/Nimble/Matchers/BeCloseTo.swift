import Foundation

// swiftlint:disable:next identifier_name
public let DefaultDelta: Double = 0.0001

public func defaultDelta<F: FloatingPoint>() -> F { 1/10000 /* 0.0001 */ }

internal func isCloseTo<Value: FloatingPoint>(
    _ actualValue: Value?,
    expectedValue: Value,
    delta: Value
) -> MatcherResult {
    let errorMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
    return MatcherResult(
        bool: actualValue != nil &&
            abs(actualValue! - expectedValue) < delta,
        message: .expectedCustomValueTo(errorMessage, actual: "<\(stringify(actualValue))>")
    )
}

internal func isCloseTo(
    _ actualValue: NMBDoubleConvertible?,
    expectedValue: NMBDoubleConvertible,
    delta: Double
) -> MatcherResult {
    let errorMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
    return MatcherResult(
        bool: actualValue != nil &&
            abs(actualValue!.doubleValue - expectedValue.doubleValue) < delta,
        message: .expectedCustomValueTo(errorMessage, actual: "<\(stringify(actualValue))>")
    )
}

/// A Nimble matcher that succeeds when a value is close to another. This is used for floating
/// point values which can have imprecise results when doing arithmetic on them.
///
/// @see equal
public func beCloseTo<Value: FloatingPoint>(
    _ expectedValue: Value,
    within delta: Value = defaultDelta()
) -> Matcher<Value> {
    return Matcher.define { actualExpression in
        return isCloseTo(try actualExpression.evaluate(), expectedValue: expectedValue, delta: delta)
    }
}

/// A Nimble matcher that succeeds when a value is close to another. This is used for floating
/// point values which can have imprecise results when doing arithmetic on them.
///
/// @see equal
public func beCloseTo<Value: NMBDoubleConvertible>(
    _ expectedValue: Value,
    within delta: Double = DefaultDelta
) -> Matcher<Value> {
    return Matcher.define { actualExpression in
        return isCloseTo(try actualExpression.evaluate(), expectedValue: expectedValue, delta: delta)
    }
}

private func beCloseTo(
    _ expectedValue: NMBDoubleConvertible,
    within delta: Double = DefaultDelta
) -> Matcher<NMBDoubleConvertible> {
    return Matcher.define { actualExpression in
        return isCloseTo(try actualExpression.evaluate(), expectedValue: expectedValue, delta: delta)
    }
}

#if canImport(Darwin)
public class NMBObjCBeCloseToMatcher: NMBMatcher {
    private let _expected: NSNumber

    fileprivate init(expected: NSNumber, within: CDouble) {
        _expected = expected

        let matcher = beCloseTo(expected, within: within)
        let matcherBlock: MatcherBlock = { actualExpression in
            let expr = actualExpression.cast { $0 as? NMBDoubleConvertible }
            return try matcher.satisfies(expr).toObjectiveC()
        }
        super.init(matcher: matcherBlock)
    }

    @objc public var within: (CDouble) -> NMBObjCBeCloseToMatcher {
        let expected = _expected
        return { delta in
            return NMBObjCBeCloseToMatcher(expected: expected, within: delta)
        }
    }
}

extension NMBMatcher {
    @objc public class func beCloseToMatcher(_ expected: NSNumber, within: CDouble) -> NMBObjCBeCloseToMatcher {
        return NMBObjCBeCloseToMatcher(expected: expected, within: within)
    }
}
#endif

public func beCloseTo<Value: FloatingPoint, Values: Collection>(
    _ expectedValues: Values,
    within delta: Value = defaultDelta()
) -> Matcher<Values> where Values.Element == Value {
    let errorMessage = "be close to <\(stringify(expectedValues))> (each within \(stringify(delta)))"
    return Matcher.simple(errorMessage) { actualExpression in
        guard let actualValues = try actualExpression.evaluate() else {
            return .doesNotMatch
        }

        if actualValues.count != expectedValues.count {
            return .doesNotMatch
        }

        for index in actualValues.indices where abs(actualValues[index] - expectedValues[index]) > delta {
            return .doesNotMatch
        }
        return .matches
    }
}

// MARK: - Operators

infix operator ≈ : ComparisonPrecedence

// swiftlint:disable identifier_name
public func ≈ <Value>(lhs: SyncExpectation<Value>, rhs: Value) where Value: Collection, Value.Element: FloatingPoint {
    lhs.to(beCloseTo(rhs))
}

public func ≈ <Value>(lhs: AsyncExpectation<Value>, rhs: Value) async where Value: Collection, Value.Element: FloatingPoint {
    await lhs.to(beCloseTo(rhs))
}

public func ≈ <Value: FloatingPoint>(lhs: SyncExpectation<Value>, rhs: Value) {
    lhs.to(beCloseTo(rhs))
}

public func ≈ <Value: FloatingPoint>(lhs: AsyncExpectation<Value>, rhs: Value) async {
    await lhs.to(beCloseTo(rhs))
}

public func ≈ <Value: FloatingPoint>(lhs: SyncExpectation<Value>, rhs: (expected: Value, delta: Value)) {
    lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

public func ≈ <Value: FloatingPoint>(lhs: AsyncExpectation<Value>, rhs: (expected: Value, delta: Value)) async {
    await lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

public func == <Value: FloatingPoint>(lhs: SyncExpectation<Value>, rhs: (expected: Value, delta: Value)) {
    lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

public func == <Value: FloatingPoint>(lhs: AsyncExpectation<Value>, rhs: (expected: Value, delta: Value)) async {
    await lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

public func ≈ <Value: NMBDoubleConvertible>(lhs: SyncExpectation<Value>, rhs: Value) {
    lhs.to(beCloseTo(rhs))
}

public func ≈ <Value: NMBDoubleConvertible>(lhs: AsyncExpectation<Value>, rhs: Value) async {
    await lhs.to(beCloseTo(rhs))
}

public func ≈ <Value: NMBDoubleConvertible>(lhs: SyncExpectation<Value>, rhs: (expected: Value, delta: Double)) {
    lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

public func ≈ <Value: NMBDoubleConvertible>(lhs: AsyncExpectation<Value>, rhs: (expected: Value, delta: Double)) async {
    await lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

public func == <Value: NMBDoubleConvertible>(lhs: SyncExpectation<Value>, rhs: (expected: Value, delta: Double)) {
    lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

public func == <Value: NMBDoubleConvertible>(lhs: AsyncExpectation<Value>, rhs: (expected: Value, delta: Double)) async {
    await lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

// make this higher precedence than exponents so the Doubles either end aren't pulled in
// unexpectantly
precedencegroup PlusMinusOperatorPrecedence {
    higherThan: BitwiseShiftPrecedence
}

infix operator ± : PlusMinusOperatorPrecedence
public func ± <Value: FloatingPoint>(lhs: Value, rhs: Value) -> (expected: Value, delta: Value) {
    return (expected: lhs, delta: rhs)
}
public func ± <Value: NMBDoubleConvertible>(lhs: Value, rhs: Double) -> (expected: Value, delta: Double) {
    return (expected: lhs, delta: rhs)
}

// swiftlint:enable identifier_name
