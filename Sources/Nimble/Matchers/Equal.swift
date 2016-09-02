import Foundation

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// - SeeAlso: `beCloseTo(_:)` for matching imprecise types (eg - floats, doubles) and
///    `beNil()` for matching `nil`.
public func equal<T: Equatable>(expectedValue: T) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        return actualValue == expectedValue
    }
}

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// - SeeAlso: `beCloseTo(_:)` for matching imprecise types (eg - floats, doubles) and
///    `beNil()` for matching `nil`.
public func equal<T: Equatable, C: Equatable>(expectedValue: [T: C]) -> NonNilMatcherFunc<[T: C]> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"
        guard let actualValue = try actualExpression.evaluate() else { return false }
        return expectedValue == actualValue
    }
}

/// A Nimble matcher that succeeds when the actual collection is equal to the expected collection.
/// Items must implement the Equatable protocol.
public func equal<T: Equatable>(expectedValue: [T]) -> NonNilMatcherFunc<[T]> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"
        let _actualValue = try actualExpression.evaluate()
        guard let actualValue = _actualValue else { return false }
        return expectedValue == actualValue
    }
}

/// A Nimble matcher allowing comparison of collection with optional type
public func equal<T: Equatable>(expectedValue: [T?]) -> NonNilMatcherFunc<[T?]> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"
        if let actualValue = try actualExpression.evaluate() {
            if expectedValue.count != actualValue.count {
                return false
            }
            
            for (index, item) in actualValue.enumerate() {
                let otherItem = expectedValue[index]
                if item == nil && otherItem == nil {
                    continue
                } else if item == nil && otherItem != nil {
                    return false
                } else if item != nil && otherItem == nil {
                    return false
                } else if item! != otherItem! {
                    return false
                }
            }
            
            return true
        } else {
            failureMessage.postfixActual = " (use beNil() to match nils)"
        }
        
        return false
    }
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T>(expectedValue: Set<T>) -> NonNilMatcherFunc<Set<T>> {
    return equal(expectedValue, stringify: stringify)
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T: Comparable>(expectedValue: Set<T>) -> NonNilMatcherFunc<Set<T>> {
    return equal(expectedValue, stringify: {
        var output = Array($0)
        output.sortInPlace(<)
        return stringify(output)
    })
}

private func equal<T>(expectedValue: Set<T>, stringify: Set<T> -> String) -> NonNilMatcherFunc<Set<T>> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"

        if let actualValue = try actualExpression.evaluate() {
            failureMessage.actualValue = "<\(stringify(actualValue))>"

            if expectedValue == actualValue {
                return true
            }

            let missing = expectedValue.subtract(actualValue)
            if missing.count > 0 {
                failureMessage.postfixActual += ", missing <\(stringify(missing))>"
            }

            let extra = actualValue.subtract(expectedValue)
            if extra.count > 0 {
                failureMessage.postfixActual += ", extra <\(stringify(extra))>"
            }
        }

        return false
    }
}

public func ==<T: Equatable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: Expectation<T>, rhs: T) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Equatable>(lhs: Expectation<[T]>, rhs: [T]) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: Expectation<[T]>, rhs: [T]) {
    lhs.toNot(equal(rhs))
}

public func ==<T>(lhs: Expectation<Set<T>>, rhs: Set<T>) {
    lhs.to(equal(rhs))
}

public func !=<T>(lhs: Expectation<Set<T>>, rhs: Set<T>) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Comparable>(lhs: Expectation<Set<T>>, rhs: Set<T>) {
    lhs.to(equal(rhs))
}

public func !=<T: Comparable>(lhs: Expectation<Set<T>>, rhs: Set<T>) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Equatable, C: Equatable>(lhs: Expectation<[T: C]>, rhs: [T: C]) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable, C: Equatable>(lhs: Expectation<[T: C]>, rhs: [T: C]) {
    lhs.toNot(equal(rhs))
}

#if _runtime(_ObjC)
extension NMBObjCMatcher {
    public class func equalMatcher(expected: NSObject?) -> NMBMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            guard let expected = expected else {
                failureMessage.postfixMessage = "equal <\(stringify(try! actualExpression.evaluate()))>"
                failureMessage.postfixActual = " (use beNil() to match nils)"
                return false
            }
            return try! equal(expected).matches(actualExpression, failureMessage: failureMessage)
        }
    }
}
#endif
