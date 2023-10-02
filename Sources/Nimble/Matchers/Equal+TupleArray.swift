// swiftlint:disable large_tuple

// MARK: Tuple2 Array

/// A Nimble matcher that succeeds when the actual array of tuples is equal to the expected array of tuples.
/// Values can support equal by supporting the Equatable protocol.
public func equal<T1: Equatable, T2: Equatable>(
    _ expectedValue: [(T1, T2)]?
) -> Matcher<[(T1, T2)]> {
    equalTupleArray(expectedValue, by: ==)
}

public func == <T1: Equatable, T2: Equatable>(
    lhs: SyncExpectation<[(T1, T2)]>,
    rhs: [(T1, T2)]?
) {
    lhs.to(equal(rhs))
}

public func == <T1: Equatable, T2: Equatable>(
    lhs: AsyncExpectation<[(T1, T2)]>,
    rhs: [(T1, T2)]?
) async {
    await lhs.to(equal(rhs))
}

public func != <T1: Equatable, T2: Equatable>(
    lhs: SyncExpectation<[(T1, T2)]>,
    rhs: [(T1, T2)]?
) {
    lhs.toNot(equal(rhs))
}

public func != <T1: Equatable, T2: Equatable>(
    lhs: AsyncExpectation<[(T1, T2)]>,
    rhs: [(T1, T2)]?
) async {
    await lhs.toNot(equal(rhs))
}

// MARK: Tuple3 Array

/// A Nimble matcher that succeeds when the actual array of tuples is equal to the expected array of tuples.
/// Values can support equal by supporting the Equatable protocol.
public func equal<T1: Equatable, T2: Equatable, T3: Equatable>(
    _ expectedValue: [(T1, T2, T3)]?
) -> Matcher<[(T1, T2, T3)]> {
    equalTupleArray(expectedValue, by: ==)
}

public func == <T1: Equatable, T2: Equatable, T3: Equatable>(
    lhs: SyncExpectation<[(T1, T2, T3)]>,
    rhs: [(T1, T2, T3)]?
) {
    lhs.to(equal(rhs))
}

public func == <T1: Equatable, T2: Equatable, T3: Equatable>(
    lhs: AsyncExpectation<[(T1, T2, T3)]>,
    rhs: [(T1, T2, T3)]?
) async {
    await lhs.to(equal(rhs))
}

public func != <T1: Equatable, T2: Equatable, T3: Equatable>(
    lhs: SyncExpectation<[(T1, T2, T3)]>,
    rhs: [(T1, T2, T3)]?
) {
    lhs.toNot(equal(rhs))
}

public func != <T1: Equatable, T2: Equatable, T3: Equatable>(
    lhs: AsyncExpectation<[(T1, T2, T3)]>,
    rhs: [(T1, T2, T3)]?
) async {
    await lhs.toNot(equal(rhs))
}

// MARK: Tuple4 Array

/// A Nimble matcher that succeeds when the actual array of tuples is equal to the expected array of tuples.
/// Values can support equal by supporting the Equatable protocol.
public func equal<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable>(
    _ expectedValue: [(T1, T2, T3, T4)]?
) -> Matcher<[(T1, T2, T3, T4)]> {
    equalTupleArray(expectedValue, by: ==)
}

public func == <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable>(
    lhs: SyncExpectation<[(T1, T2, T3, T4)]>,
    rhs: [(T1, T2, T3, T4)]?
) {
    lhs.to(equal(rhs))
}

public func == <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable>(
    lhs: AsyncExpectation<[(T1, T2, T3, T4)]>,
    rhs: [(T1, T2, T3, T4)]?
) async {
    await lhs.to(equal(rhs))
}

public func != <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable>(
    lhs: SyncExpectation<[(T1, T2, T3, T4)]>,
    rhs: [(T1, T2, T3, T4)]?
) {
    lhs.toNot(equal(rhs))
}

public func != <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable>(
    lhs: AsyncExpectation<[(T1, T2, T3, T4)]>,
    rhs: [(T1, T2, T3, T4)]?
) async {
    await lhs.toNot(equal(rhs))
}

// MARK: Tuple5 Array

/// A Nimble matcher that succeeds when the actual array of tuples is equal to the expected array of tuples.
/// Values can support equal by supporting the Equatable protocol.
public func equal<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable>(
    _ expectedValue: [(T1, T2, T3, T4, T5)]?
) -> Matcher<[(T1, T2, T3, T4, T5)]> {
    equalTupleArray(expectedValue, by: ==)
}

public func == <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable>(
    lhs: SyncExpectation<[(T1, T2, T3, T4, T5)]>,
    rhs: [(T1, T2, T3, T4, T5)]?
) {
    lhs.to(equal(rhs))
}

public func == <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable>(
    lhs: AsyncExpectation<[(T1, T2, T3, T4, T5)]>,
    rhs: [(T1, T2, T3, T4, T5)]?
) async {
    await lhs.to(equal(rhs))
}

public func != <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable>(
    lhs: SyncExpectation<[(T1, T2, T3, T4, T5)]>,
    rhs: [(T1, T2, T3, T4, T5)]?
) {
    lhs.toNot(equal(rhs))
}

public func != <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable>(
    lhs: AsyncExpectation<[(T1, T2, T3, T4, T5)]>,
    rhs: [(T1, T2, T3, T4, T5)]?
) async {
    await lhs.toNot(equal(rhs))
}

// MARK: Tuple6 Array

/// A Nimble matcher that succeeds when the actual array of tuples is equal to the expected array of tuples.
/// Values can support equal by supporting the Equatable protocol.
public func equal<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable>(
    _ expectedValue: [(T1, T2, T3, T4, T5, T6)]?
) -> Matcher<[(T1, T2, T3, T4, T5, T6)]> {
    equalTupleArray(expectedValue, by: ==)
}

public func == <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable>(
    lhs: SyncExpectation<[(T1, T2, T3, T4, T5, T6)]>,
    rhs: [(T1, T2, T3, T4, T5, T6)]?
) {
    lhs.to(equal(rhs))
}

public func == <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable>(
    lhs: AsyncExpectation<[(T1, T2, T3, T4, T5, T6)]>,
    rhs: [(T1, T2, T3, T4, T5, T6)]?
) async {
    await lhs.to(equal(rhs))
}

public func != <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable>(
    lhs: SyncExpectation<[(T1, T2, T3, T4, T5, T6)]>,
    rhs: [(T1, T2, T3, T4, T5, T6)]?
) {
    lhs.toNot(equal(rhs))
}

public func != <T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable, T6: Equatable>(
    lhs: AsyncExpectation<[(T1, T2, T3, T4, T5, T6)]>,
    rhs: [(T1, T2, T3, T4, T5, T6)]?
) async {
    await lhs.toNot(equal(rhs))
}

// swiftlint:enable large_tuple

// MARK: Implementation Helpers

private func equalTupleArray<Tuple>(
    _ expectedValue: [(Tuple)]?,
    by areTuplesEquivalent: @escaping (Tuple, Tuple) -> Bool
) -> Matcher<[Tuple]> {
    equal(expectedValue) {
        $0.elementsEqual($1, by: areTuplesEquivalent)
    }
}
