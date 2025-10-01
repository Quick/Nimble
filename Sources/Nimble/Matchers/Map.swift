/// `map` works by transforming the expression to a value that the given matcher uses.
///
/// For example, you might only care that a particular property on a method equals some other value.
/// So, you could write `expect(myObject).to(map(\.someIntValue, equal(3))`.
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
/// So, you could write `expect(myObject).to(map(\.someIntValue, equal(3))`.
/// This is also useful in conjunction with ``satisfyAllOf`` to do a partial equality of an object.
public func map<T, U>(_ transform: @escaping (T) async throws -> U, _ matcher: some AsyncableMatcher<U>) -> AsyncMatcher<T> {
    AsyncMatcher { (received: AsyncExpression<T>) in
        try await matcher.satisfies(received.cast { value in
            guard let value else { return nil }
            return try await transform(value)
        })
    }
}

/// `map` works by transforming the expression to a value that the given matcher uses.
///
/// For example, you might only care that a particular property on a method equals some other value.
/// So, you could write `expect(myObject).to(map(\.someOptionalIntValue, equal(3))`.
/// This is also useful in conjunction with ``satisfyAllOf`` to do a partial equality of an object.
public func map<T, U>(_ transform: @escaping (T) throws -> U?, _ matcher: Matcher<U>) -> Matcher<T> {
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
/// So, you could write `expect(myObject).to(map(\.someOptionalIntValue, equal(3))`.
/// This is also useful in conjunction with ``satisfyAllOf`` to do a partial equality of an object.
public func map<T, U>(_ transform: @escaping (T) async throws -> U?, _ matcher: some AsyncableMatcher<U>) -> AsyncMatcher<T> {
    AsyncMatcher { (received: AsyncExpression<T>) in
        try await matcher.satisfies(received.cast { value in
            guard let value else { return nil }
            return try await transform(value)
        })
    }
}

/// `compactMap` works by transforming the expression to a value that the given matcher uses.
///
/// For example, you might only care that a particular property on a method equals some other value.
/// So, you could write `expect(myObject).to(compactMap({ $0 as? Int }, equal(3))`.
/// This is also useful in conjunction with ``satisfyAllOf`` to match against a converted type.
public func compactMap<T, U>(_ transform: @escaping (T) throws -> U?, _ matcher: Matcher<U>) -> Matcher<T> {
    Matcher { (received: Expression<T>) in
        let message = ExpectationMessage.expectedTo("Map from \(T.self) to \(U.self)")

        guard let value = try received.evaluate() else {
            return MatcherResult(status: .fail, message: message.appendedBeNilHint())
        }

        guard let transformedValue = try transform(value) else {
            return MatcherResult(status: .fail, message: message)
        }

        return try matcher.satisfies(Expression(expression: { transformedValue }, location: received.location))
    }
}

/// `compactMap` works by transforming the expression to a value that the given matcher uses.
///
/// For example, you might only care that a particular property on a method equals some other value.
/// So, you could write `expect(myObject).to(compactMap({ $0 as? Int }, equal(3))`.
/// This is also useful in conjunction with ``satisfyAllOf`` to match against a converted type.
public func compactMap<T, U>(_ transform: @escaping (T) async throws -> U?, _ matcher: some AsyncableMatcher<U>) -> AsyncMatcher<T> {
    AsyncMatcher { (received: AsyncExpression<T>) in
        let message = ExpectationMessage.expectedTo("Map from \(T.self) to \(U.self)")

        guard let value = try await received.evaluate() else {
            return MatcherResult(status: .fail, message: message.appendedBeNilHint())
        }

        guard let transformedValue = try await transform(value) else {
            return MatcherResult(status: .fail, message: message)
        }

        return try await matcher.satisfies(AsyncExpression(expression: { transformedValue }, location: received.location))
    }
}
