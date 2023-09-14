public protocol AsyncablePredicate<Value> {
    associatedtype Value
    func satisfies(_ expression: AsyncExpression<Value>) async throws -> PredicateResult
}

extension Predicate: AsyncablePredicate {
    public func satisfies(_ expression: AsyncExpression<T>) async throws -> PredicateResult {
        try satisfies(await expression.toSynchronousExpression())
    }
}

/// An AsyncPredicate is part of the new matcher API that provides assertions to expectations.
///
/// Given a code snippet:
///
///   expect(1).to(equal(2))
///                ^^^^^^^^
///            Called a "matcher"
///
/// A matcher consists of two parts a constructor function and the Predicate. The term Predicate
/// is used as a separate name from Matcher to help transition custom matchers to the new Nimble
/// matcher API.
///
/// The Predicate provide the heavy lifting on how to assert against a given value. Internally,
/// predicates are simple wrappers around closures to provide static type information and
/// allow composition and wrapping of existing behaviors.
///
/// `AsyncPredicate`s serve to allow writing matchers that must be run in async contexts.
/// These can also be used with either `Expectation`s or `AsyncExpectation`s.
/// But these can only be used from async contexts, and are unavailable in Objective-C.
/// You can, however, call regular Predicates from an AsyncPredicate, if you wish to compose one like that.
public struct AsyncPredicate<T>: AsyncablePredicate {
    fileprivate var matcher: (AsyncExpression<T>) async throws -> PredicateResult

    public init(_ matcher: @escaping (AsyncExpression<T>) async throws -> PredicateResult) {
        self.matcher = matcher
    }

    /// Uses a predicate on a given value to see if it passes the predicate.
    ///
    /// @param expression The value to run the predicate's logic against
    /// @returns A predicate result indicate passing or failing and an associated error message.
    public func satisfies(_ expression: AsyncExpression<T>) async throws -> PredicateResult {
        return try await matcher(expression)
    }
}

/// Provides convenience helpers to defining predicates
extension AsyncPredicate {
    /// Like Predicate() constructor, but automatically guard against nil (actual) values
    public static func define(matcher: @escaping (AsyncExpression<T>) async throws -> PredicateResult) -> AsyncPredicate<T> {
        return AsyncPredicate<T> { actual in
            return try await matcher(actual)
        }.requireNonNil
    }

    /// Defines a predicate with a default message that can be returned in the closure
    /// Also ensures the predicate's actual value cannot pass with `nil` given.
    public static func define(_ message: String = "match", matcher: @escaping (AsyncExpression<T>, ExpectationMessage) async throws -> PredicateResult) -> AsyncPredicate<T> {
        return AsyncPredicate<T> { actual in
            return try await matcher(actual, .expectedActualValueTo(message))
        }.requireNonNil
    }

    /// Defines a predicate with a default message that can be returned in the closure
    /// Unlike `define`, this allows nil values to succeed if the given closure chooses to.
    public static func defineNilable(_ message: String = "match", matcher: @escaping (AsyncExpression<T>, ExpectationMessage) async throws -> PredicateResult) -> AsyncPredicate<T> {
        return AsyncPredicate<T> { actual in
            return try await matcher(actual, .expectedActualValueTo(message))
        }
    }

    /// Provides a simple predicate definition that provides no control over the predefined
    /// error message.
    ///
    /// Also ensures the predicate's actual value cannot pass with `nil` given.
    public static func simple(_ message: String = "match", matcher: @escaping (AsyncExpression<T>) async throws -> PredicateStatus) -> AsyncPredicate<T> {
        return AsyncPredicate<T> { actual in
            return PredicateResult(status: try await matcher(actual), message: .expectedActualValueTo(message))
        }.requireNonNil
    }

    /// Provides a simple predicate definition that provides no control over the predefined
    /// error message.
    ///
    /// Unlike `simple`, this allows nil values to succeed if the given closure chooses to.
    public static func simpleNilable(_ message: String = "match", matcher: @escaping (AsyncExpression<T>) async throws -> PredicateStatus) -> AsyncPredicate<T> {
        return AsyncPredicate<T> { actual in
            return PredicateResult(status: try await matcher(actual), message: .expectedActualValueTo(message))
        }
    }
}

extension AsyncPredicate {
    // Someday, make this public? Needs documentation
    internal func after(f: @escaping (AsyncExpression<T>, PredicateResult) async throws -> PredicateResult) -> AsyncPredicate<T> {
        // swiftlint:disable:previous identifier_name
        return AsyncPredicate { actual -> PredicateResult in
            let result = try await self.satisfies(actual)
            return try await f(actual, result)
        }
    }

    /// Returns a new Predicate based on the current one that always fails if nil is given as
    /// the actual value.
    public var requireNonNil: AsyncPredicate<T> {
        return after { actual, result in
            if try await actual.evaluate() == nil {
                return PredicateResult(
                    status: .fail,
                    message: result.message.appendedBeNilHint()
                )
            }
            return result
        }
    }
}
