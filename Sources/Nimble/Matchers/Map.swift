/// `map` works by transforming the expression to a value that the given matcher uses.
///
/// For example, you might only care that a particular property on a method equals some other value.
/// So, you could write `expect(myObject).to(lens(\.someIntValue, equal(3))`.
/// This is also useful in conjunction with ``satisfyAllOf`` to do a partial equality of an object.
public func map<T, U>(_ transform: @escaping (T) throws -> U, _ matcher: Matcher<U>) -> Matcher<T> {
    Matcher { (received: Expression<T>) in
        try matcher.satisfies(received.cast { value in
            guard let value else { return nil }
            return try transform(value)
        })
    }
}

/// `map` works by transforming the expression to a value that the given matcher uses.
///
/// For example, you might only care that a particular property on a method equals some other value.
/// So, you could write `expect(myObject).to(lens(\.someIntValue, equal(3))`.
/// This is also useful in conjunction with ``satisfyAllOf`` to do a partial equality of an object.
public func map<T, U>(_ transform: @escaping (T) async throws -> U, _ matcher: some AsyncableMatcher<U>) -> AsyncMatcher<T> {
    AsyncMatcher { (received: AsyncExpression<T>) in
        try await matcher.satisfies(received.cast { value in
            guard let value else { return nil }
            return try await transform(value)
        })
    }
}
