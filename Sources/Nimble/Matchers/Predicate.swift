// New Matcher API
//

/// A Predicate is part of the new matcher API that provides assertions to expectations.
///
/// Given a code snippet:
///
///   expect(1).to(equal(2))
///                ^^^^^^^^
///            Called a "matcher"
///
/// A matcher usually consists of two parts a constructor function and the Predicate.
///
/// The Predicate provide the heavy lifting on how to assert against a given value. Internally,
/// Predicates are simple wrappers around closures to provide static type information and
/// allow composition and wrapping of existing behaviors.
public struct Predicate<T> {
    private var matcher: (Expression<T>, FailureMessage, Bool) throws -> Bool

    /// Constructs a predicate that knows how take a given value
    public init(_ matcher: @escaping (Expression<T>, FailureMessage, Bool) throws -> Bool) {
        self.matcher = matcher
    }

    public init(_ matcher: @escaping (Expression<T>, FailureMessage) throws -> Bool) {
        self.matcher = ({ actual, failureMessage, expectedResult in
            return try matcher(actual, failureMessage) == expectedResult
        })
    }

    public func satisfies(_ expression: Expression<T>, _ failureMessage: FailureMessage, expectMatch: Bool) throws -> Bool {
        return try matcher(expression, failureMessage, expectMatch)
    }
}

// Backwards compatibility until Old Matcher API removal
extension Predicate: Matcher {
    public init<M>(_ matcher: M) where M: Matcher, M.ValueType == T {
        self.init(matcher.toClosure)
    }

    public func matches(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        return try satisfies(actualExpression, failureMessage, expectMatch: true)
    }

    public func doesNotMatch(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        return try satisfies(actualExpression, failureMessage, expectMatch: false)
    }
}

extension Predicate {
    // Someday, make this public? Needs documentation
    internal func before(f: @escaping (Expression<T>, FailureMessage, Bool) throws -> Bool) -> Predicate<T> {
        return Predicate { actual, msg, expectMatch in
            if try f(actual, msg, expectMatch) {
                return try self.satisfies(actual, msg, expectMatch: expectMatch)
            } else {
                _ = try self.satisfies(actual, msg, expectMatch: expectMatch)
                return false
            }
        }
    }

    // Someday, make this public? Needs documentation
    internal func after(f: @escaping (Expression<T>, FailureMessage, Bool) throws -> Bool) -> Predicate<T> {
        return Predicate { actual, msg, expectMatch in
            if try self.satisfies(actual, msg, expectMatch: expectMatch) {
                return try f(actual, msg, expectMatch)
            } else {
                _ = try f(actual, msg, expectMatch)
                return false
            }
        }
    }

    /// Returns a new Predicate based on the current one that always fails if nil is given as
    /// the actual value.
    ///
    /// This replaces `NonNilMatcherFunc`.
    public var requireNonNil: Predicate<T> {
        return after { actual, failureMessage, _ in
            if try actual.evaluate() == nil {
                failureMessage.postfixActual = " (use beNil() to match nils)"
                return false
            }
            return true
        }
    }
}
