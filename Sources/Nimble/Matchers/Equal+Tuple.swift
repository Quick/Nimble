// swiftlint:disable large_tuple vertical_whitespace

// MARK: Tuple2

/// A Nimble matcher that succeeds when the actual tuple is equal to the expected tuple.
/// Values can support equal by supporting the Equatable protocol.
public func equal<T1: Equatable, T2: Equatable>(
    _ expectedValue: (T1, T2)?
) -> Predicate<(T1, T2)> {
    equal(expectedValue, by: ==)
}

public func ==<T1: Equatable, T2: Equatable>(
    lhs: Expectation<(T1, T2)>,
    rhs: (T1, T2)?
) {
    lhs.to(equal(rhs))
}

public func !=<T1: Equatable, T2: Equatable>(
    lhs: Expectation<(T1, T2)>,
    rhs: (T1, T2)?
) {
    lhs.toNot(equal(rhs))
}


// MARK: Tuple3

/// A Nimble matcher that succeeds when the actual tuple is equal to the expected tuple.
/// Values can support equal by supporting the Equatable protocol.
public func equal<T1: Equatable, T2: Equatable, T3: Equatable>(
    _ expectedValue: (T1, T2, T3)?
) -> Predicate<(T1, T2, T3)> {
    equal(expectedValue, by: ==)
}

public func ==<T1: Equatable, T2: Equatable, T3: Equatable>(
    lhs: Expectation<(T1, T2, T3)>,
    rhs: (T1, T2, T3)?
) {
    lhs.to(equal(rhs))
}

public func !=<T1: Equatable, T2: Equatable, T3: Equatable>(
    lhs: Expectation<(T1, T2, T3)>,
    rhs: (T1, T2, T3)?
) {
    lhs.toNot(equal(rhs))
}


// MARK: Tuple4

/// A Nimble matcher that succeeds when the actual tuple is equal to the expected tuple.
/// Values can support equal by supporting the Equatable protocol.
public func equal<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable>(
    _ expectedValue: (T1, T2, T3, T4)?
) -> Predicate<(T1, T2, T3, T4)> {
    equal(expectedValue, by: ==)
}

public func ==<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable>(
    lhs: Expectation<(T1, T2, T3, T4)>,
    rhs: (T1, T2, T3, T4)?
) {
    lhs.to(equal(rhs))
}

public func !=<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable>(
    lhs: Expectation<(T1, T2, T3, T4)>,
    rhs: (T1, T2, T3, T4)?
) {
    lhs.toNot(equal(rhs))
}


// MARK: Tuple5

/// A Nimble matcher that succeeds when the actual tuple is equal to the expected tuple.
/// Values can support equal by supporting the Equatable protocol.
public func equal<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable>(
    _ expectedValue: (T1, T2, T3, T4, T5)?
) -> Predicate<(T1, T2, T3, T4, T5)> {
    equal(expectedValue, by: ==)
}

public func ==<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable>(
    lhs: Expectation<(T1, T2, T3, T4, T5)>,
    rhs: (T1, T2, T3, T4, T5)?
) {
    lhs.to(equal(rhs))
}

public func !=<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable>(
    lhs: Expectation<(T1, T2, T3, T4, T5)>,
    rhs: (T1, T2, T3, T4, T5)?
) {
    lhs.toNot(equal(rhs))
}


// MARK: Tuple6

/// A Nimble matcher that succeeds when the actual tuple is equal to the expected tuple.
/// Values can support equal by supporting the Equatable protocol.
public func equal<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable>(
    _ expectedValue: (T1, T2, T3, T4, T5, T6)?
) -> Predicate<(T1, T2, T3, T4, T5, T6)> {
    equal(expectedValue, by: ==)
}

public func ==<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable>(
    lhs: Expectation<(T1, T2, T3, T4, T5, T6)>,
    rhs: (T1, T2, T3, T4, T5, T6)?
) {
    lhs.to(equal(rhs))
}

public func !=<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable>(
    lhs: Expectation<(T1, T2, T3, T4, T5, T6)>,
    rhs: (T1, T2, T3, T4, T5, T6)?
) {
    lhs.toNot(equal(rhs))
}

// swiftlint:enable large_tuple vertical_whitespace
