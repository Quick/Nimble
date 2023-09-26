public protocol AsyncableMatcher<Value> {
    associatedtype Value
    func satisfies(_ expression: AsyncExpression<Value>) async throws -> MatcherResult
}

extension Matcher: AsyncableMatcher {
    public func satisfies(_ expression: AsyncExpression<T>) async throws -> MatcherResult {
        try satisfies(await expression.toSynchronousExpression())
    }
}

/// An AsyncMatcher is part of the new matcher API that provides assertions to expectations.
///
/// Given a code snippet:
///
///   expect(1).to(equal(2))
///                ^^^^^^^^
///            Called a "matcher"
///
/// A matcher consists of two parts a constructor function and the Matcher.
///
/// The Matcher provide the heavy lifting on how to assert against a given value. Internally,
/// matchers are simple wrappers around closures to provide static type information and
/// allow composition and wrapping of existing behaviors.
///
/// `AsyncMatcher`s serve to allow writing matchers that must be run in async contexts.
/// These can also be used with either `Expectation`s or `AsyncExpectation`s.
/// But these can only be used from async contexts, and are unavailable in Objective-C.
/// You can, however, call regular Matchers from an AsyncMatcher, if you wish to compose one like that.
public struct AsyncMatcher<T>: AsyncableMatcher {
    fileprivate var matcher: (AsyncExpression<T>) async throws -> MatcherResult

    public init(_ matcher: @escaping (AsyncExpression<T>) async throws -> MatcherResult) {
        self.matcher = matcher
    }

    /// Uses a matcher on a given value to see if it passes the matcher.
    ///
    /// @param expression The value to run the matcher's logic against
    /// @returns A matcher result indicate passing or failing and an associated error message.
    public func satisfies(_ expression: AsyncExpression<T>) async throws -> MatcherResult {
        return try await matcher(expression)
    }
}

@available(*, deprecated, renamed: "AsyncMatcher")
public typealias AsyncPredicate = AsyncMatcher

/// Provides convenience helpers to defining matchers
extension AsyncMatcher {
    /// Like Matcher() constructor, but automatically guard against nil (actual) values
    public static func define(matcher: @escaping (AsyncExpression<T>) async throws -> MatcherResult) -> AsyncMatcher<T> {
        return AsyncMatcher<T> { actual in
            return try await matcher(actual)
        }.requireNonNil
    }

    /// Defines a matcher with a default message that can be returned in the closure
    /// Also ensures the matcher's actual value cannot pass with `nil` given.
    public static func define(_ message: String = "match", matcher: @escaping (AsyncExpression<T>, ExpectationMessage) async throws -> MatcherResult) -> AsyncMatcher<T> {
        return AsyncMatcher<T> { actual in
            return try await matcher(actual, .expectedActualValueTo(message))
        }.requireNonNil
    }

    /// Defines a matcher with a default message that can be returned in the closure
    /// Unlike `define`, this allows nil values to succeed if the given closure chooses to.
    public static func defineNilable(_ message: String = "match", matcher: @escaping (AsyncExpression<T>, ExpectationMessage) async throws -> MatcherResult) -> AsyncMatcher<T> {
        return AsyncMatcher<T> { actual in
            return try await matcher(actual, .expectedActualValueTo(message))
        }
    }

    /// Provides a simple matcher definition that provides no control over the predefined
    /// error message.
    ///
    /// Also ensures the matcher's actual value cannot pass with `nil` given.
    public static func simple(_ message: String = "match", matcher: @escaping (AsyncExpression<T>) async throws -> MatcherStatus) -> AsyncMatcher<T> {
        return AsyncMatcher<T> { actual in
            return MatcherResult(status: try await matcher(actual), message: .expectedActualValueTo(message))
        }.requireNonNil
    }

    /// Provides a simple matcher definition that provides no control over the predefined
    /// error message.
    ///
    /// Unlike `simple`, this allows nil values to succeed if the given closure chooses to.
    public static func simpleNilable(_ message: String = "match", matcher: @escaping (AsyncExpression<T>) async throws -> MatcherStatus) -> AsyncMatcher<T> {
        return AsyncMatcher<T> { actual in
            return MatcherResult(status: try await matcher(actual), message: .expectedActualValueTo(message))
        }
    }
}

extension AsyncMatcher {
    // Someday, make this public? Needs documentation
    internal func after(f: @escaping (AsyncExpression<T>, MatcherResult) async throws -> MatcherResult) -> AsyncMatcher<T> {
        // swiftlint:disable:previous identifier_name
        return AsyncMatcher { actual -> MatcherResult in
            let result = try await self.satisfies(actual)
            return try await f(actual, result)
        }
    }

    /// Returns a new Matcher based on the current one that always fails if nil is given as
    /// the actual value.
    public var requireNonNil: AsyncMatcher<T> {
        return after { actual, result in
            if try await actual.evaluate() == nil {
                return MatcherResult(
                    status: .fail,
                    message: result.message.appendedBeNilHint()
                )
            }
            return result
        }
    }
}
