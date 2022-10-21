internal func equal<T>(
    _ expectedValue: T?,
    by areEquivalent: @escaping (T, T) -> Bool
) -> Predicate<T> {
    Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (nil, _?):
            return PredicateResult(status: .fail, message: msg.appendedBeNilHint())
        case (_, nil):
            return PredicateResult(status: .fail, message: msg)
        case (let expected?, let actual?):
            let matches = areEquivalent(expected, actual)
            return PredicateResult(bool: matches, message: msg)
        }
    }
}

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T: Equatable>(_ expectedValue: T) -> Predicate<T> {
    equal(expectedValue as T?)
}

/// A Nimble matcher allowing comparison of collection with optional type
public func equal<T: Equatable>(_ expectedValue: [T?]) -> Predicate<[T?]> {
    Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: msg.appendedBeNilHint()
            )
        }

        let matches = expectedValue == actualValue
        return PredicateResult(bool: matches, message: msg)
    }
}

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T: Equatable>(_ expectedValue: T?) -> Predicate<T> {
    equal(expectedValue, by: ==)
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T>(_ expectedValue: Set<T>) -> Predicate<Set<T>> {
    equal(expectedValue as Set<T>?)
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T>(_ expectedValue: Set<T>?) -> Predicate<Set<T>> {
    equal(expectedValue, stringify: { stringify($0) })
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T: Comparable>(_ expectedValue: Set<T>) -> Predicate<Set<T>> {
    equal(expectedValue as Set<T>?)
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T: Comparable>(_ expectedValue: Set<T>?) -> Predicate<Set<T>> {
    equal(expectedValue, stringify: { set in
        stringify(set.map { Array($0).sorted(by: <) })
    })
}

private func equal<T>(_ expectedValue: Set<T>?, stringify: @escaping (Set<T>?) -> String) -> Predicate<Set<T>> {
    Predicate { actualExpression in
        var errorMessage: ExpectationMessage =
            .expectedActualValueTo("equal <\(stringify(expectedValue))>")

        guard let expectedValue = expectedValue else {
            return PredicateResult(
                status: .fail,
                message: errorMessage.appendedBeNilHint()
            )
        }

        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: errorMessage.appendedBeNilHint()
            )
        }

        errorMessage = .expectedCustomValueTo(
            "equal <\(stringify(expectedValue))>",
            actual: "<\(stringify(actualValue))>"
        )

        if expectedValue == actualValue {
            return PredicateResult(
                status: .matches,
                message: errorMessage
            )
        }

        let missing = expectedValue.subtracting(actualValue)
        if missing.count > 0 {
            errorMessage = errorMessage.appended(message: ", missing <\(stringify(missing))>")
        }

        let extra = actualValue.subtracting(expectedValue)
        if extra.count > 0 {
            errorMessage = errorMessage.appended(message: ", extra <\(stringify(extra))>")
        }
        return  PredicateResult(
            status: .doesNotMatch,
            message: errorMessage
        )
    }
}

/// A Nimble matcher that succeeds when the actual dictionary is equal to the expected dictionary
public func equal<K: Hashable, V: Equatable>(_ expectedValue: [K: V?]) -> Predicate<[K: V]> {
    Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: msg.appendedBeNilHint()
            )
        }

        let matches = expectedValue == actualValue
        return PredicateResult(bool: matches, message: msg)
    }
}

public func ==<T: Equatable>(lhs: SyncExpectation<T>, rhs: T) {
    lhs.to(equal(rhs))
}

public func ==<T: Equatable>(lhs: SyncExpectation<T>, rhs: T?) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: SyncExpectation<T>, rhs: T) {
    lhs.toNot(equal(rhs))
}

public func !=<T: Equatable>(lhs: SyncExpectation<T>, rhs: T?) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Equatable>(lhs: SyncExpectation<[T]>, rhs: [T]?) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: SyncExpectation<[T]>, rhs: [T]?) {
    lhs.toNot(equal(rhs))
}

public func == <T>(lhs: SyncExpectation<Set<T>>, rhs: Set<T>) {
    lhs.to(equal(rhs))
}

public func == <T>(lhs: SyncExpectation<Set<T>>, rhs: Set<T>?) {
    lhs.to(equal(rhs))
}

public func != <T>(lhs: SyncExpectation<Set<T>>, rhs: Set<T>) {
    lhs.toNot(equal(rhs))
}

public func != <T>(lhs: SyncExpectation<Set<T>>, rhs: Set<T>?) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Comparable>(lhs: SyncExpectation<Set<T>>, rhs: Set<T>) {
    lhs.to(equal(rhs))
}

public func ==<T: Comparable>(lhs: SyncExpectation<Set<T>>, rhs: Set<T>?) {
    lhs.to(equal(rhs))
}

public func !=<T: Comparable>(lhs: SyncExpectation<Set<T>>, rhs: Set<T>) {
    lhs.toNot(equal(rhs))
}

public func !=<T: Comparable>(lhs: SyncExpectation<Set<T>>, rhs: Set<T>?) {
    lhs.toNot(equal(rhs))
}

public func ==<T, C: Equatable>(lhs: SyncExpectation<[T: C]>, rhs: [T: C]?) {
    lhs.to(equal(rhs))
}

public func !=<T, C: Equatable>(lhs: SyncExpectation<[T: C]>, rhs: [T: C]?) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Equatable>(lhs: AsyncExpectation<T>, rhs: T) {
    lhs.to(equal(rhs))
}

public func ==<T: Equatable>(lhs: AsyncExpectation<T>, rhs: T?) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: AsyncExpectation<T>, rhs: T) {
    lhs.toNot(equal(rhs))
}

public func !=<T: Equatable>(lhs: AsyncExpectation<T>, rhs: T?) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Equatable>(lhs: AsyncExpectation<[T]>, rhs: [T]?) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: AsyncExpectation<[T]>, rhs: [T]?) {
    lhs.toNot(equal(rhs))
}

public func == <T>(lhs: AsyncExpectation<Set<T>>, rhs: Set<T>) {
    lhs.to(equal(rhs))
}

public func == <T>(lhs: AsyncExpectation<Set<T>>, rhs: Set<T>?) {
    lhs.to(equal(rhs))
}

public func != <T>(lhs: AsyncExpectation<Set<T>>, rhs: Set<T>) {
    lhs.toNot(equal(rhs))
}

public func != <T>(lhs: AsyncExpectation<Set<T>>, rhs: Set<T>?) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Comparable>(lhs: AsyncExpectation<Set<T>>, rhs: Set<T>) {
    lhs.to(equal(rhs))
}

public func ==<T: Comparable>(lhs: AsyncExpectation<Set<T>>, rhs: Set<T>?) {
    lhs.to(equal(rhs))
}

public func !=<T: Comparable>(lhs: AsyncExpectation<Set<T>>, rhs: Set<T>) {
    lhs.toNot(equal(rhs))
}

public func !=<T: Comparable>(lhs: AsyncExpectation<Set<T>>, rhs: Set<T>?) {
    lhs.toNot(equal(rhs))
}

public func ==<T, C: Equatable>(lhs: AsyncExpectation<[T: C]>, rhs: [T: C]?) {
    lhs.to(equal(rhs))
}

public func !=<T, C: Equatable>(lhs: AsyncExpectation<[T: C]>, rhs: [T: C]?) {
    lhs.toNot(equal(rhs))
}

#if canImport(Darwin)
import class Foundation.NSObject

extension NMBPredicate {
    @objc public class func equalMatcher(_ expected: NSObject) -> NMBPredicate {
        NMBPredicate { actualExpression in
            try equal(expected).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
