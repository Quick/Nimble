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
/// predicates are simple wrappers around closures to provide static type information and
/// allow composition and wrapping of existing behaviors.
public struct Predicate<T> {
    fileprivate var matcher: (Expression<T>, ExpectationStyle) throws -> PredicateResult

    /// Constructs a predicate that knows how take a given value
    public init(_ matcher: @escaping (Expression<T>, ExpectationStyle) throws -> PredicateResult) {
        self.matcher = matcher
    }

    public func satisfies(_ expression: Expression<T>, _ style: ExpectationStyle) throws -> PredicateResult {
        return try matcher(expression, style)
    }
}

extension Predicate {
    public static func define(matcher: @escaping (Expression<T>) throws -> (Satisfiability, ExpectationMessage)) -> Predicate<T> {
        return Predicate<T> { actual, _ -> PredicateResult in
            let (satisfy, msg) = try matcher(actual)
            return PredicateResult(status: satisfy, message: msg)
        }.requireNonNil
    }

    public static func define(_ msg: ExpectationMessage, matcher: @escaping (Expression<T>) throws -> Satisfiability) -> Predicate<T> {
        return Predicate<T> { actual, _ -> PredicateResult in
            return PredicateResult(status: try matcher(actual), message: msg)
        }.requireNonNil
    }

    public static func define(_ msg: String, matcher: @escaping (Expression<T>) throws -> Satisfiability) -> Predicate<T> {
        return Predicate<T>.define(.ExpectedActualValueTo(msg), matcher: matcher)
    }

    public static func define(_ msg: String, matcher: @escaping (Expression<T>, ExpectationMessage) throws -> PredicateResult) -> Predicate<T> {
        return Predicate<T> { actual, _ -> PredicateResult in
            do {
                return try matcher(actual, .ExpectedActualValueTo(msg))
            } catch let error {
                return PredicateResult(unexpectedError: error, message: msg)
            }
        }.requireNonNil
    }

    public static func defineNilable(matcher: @escaping (Expression<T>) throws -> (Satisfiability, ExpectationMessage)) -> Predicate<T> {
        return Predicate<T> { actual, _ -> PredicateResult in
            let (satisfy, msg) = try matcher(actual)
            return PredicateResult(status: satisfy, message: msg)
        }
    }

    public static func defineNilable(_ msg: ExpectationMessage, matcher: @escaping (Expression<T>) throws -> Satisfiability) -> Predicate<T> {
        return Predicate<T> { actual, _ -> PredicateResult in
            return PredicateResult(status: try matcher(actual), message: msg)
        }
    }

    public static func defineNilable(_ msg: String, matcher: @escaping (Expression<T>) throws -> Satisfiability) -> Predicate<T> {
        return Predicate<T>.defineNilable(.ExpectedActualValueTo(msg), matcher: matcher)
    }

    public static func defineNilable(_ msg: String, matcher: @escaping (Expression<T>, ExpectationMessage) throws -> PredicateResult) -> Predicate<T> {
        return Predicate<T> { actual, _ -> PredicateResult in
            do {
                return try matcher(actual, .ExpectedActualValueTo(msg))
            } catch let error {
                return PredicateResult(unexpectedError: error, message: msg)
            }
        }
    }
}

public enum ExpectationStyle {
    case ToMatch, ToNotMatch
}

public struct PredicateResult {
    let status: Satisfiability
    let message: ExpectationMessage

    public init(status: Satisfiability, message: ExpectationMessage) {
        self.status = status
        self.message = message
    }

    public init(unexpectedError: Error, message: String) {
        self.status = .Fail
        self.message = .ExpectedValueTo(message, "an unexpected error thrown: \(unexpectedError)")
    }

    public func toBoolean(expectation style: ExpectationStyle) -> Bool {
        return status.toBoolean(expectation: style)
    }
}

/// Satisfiability is a trinary that indicates if a Predicate matches a given value or not
public enum Satisfiability {
    case Matches, DoesNotMatch, Fail

    public init(bool matches: Bool) {
        if matches {
            self = .Matches
        } else {
            self = .DoesNotMatch
        }
    }

    internal static func from(matches: Bool, style: ExpectationStyle) -> Satisfiability {
        switch style {
        case .ToMatch:
            if matches {
                return .Matches
            } else {
                return .DoesNotMatch
            }
        case .ToNotMatch:
            if matches {
                return .DoesNotMatch
            } else {
                return .Matches
            }
        }
    }

    private func doesMatch() -> Bool {
        switch self {
        case .Matches: return true
        case .DoesNotMatch, .Fail: return false
        }
    }

    private func doesNotMatch() -> Bool {
        switch self {
        case .DoesNotMatch: return true
        case .Matches, .Fail: return false
        }
    }

    public func toBoolean(expectation style: ExpectationStyle) -> Bool {
        if style == .ToMatch {
            return doesMatch()
        } else {
            return doesNotMatch()
        }
    }
}

// Backwards compatibility until Old Matcher API removal
extension Predicate: Matcher {
    public static func fromBoolResult(_ matcher: @escaping (Expression<T>, FailureMessage, Bool) throws -> Bool) -> Predicate {
        return Predicate { actual, style in
            let failureMessage = FailureMessage()
            let result = try matcher(actual, failureMessage, style == .ToMatch)
            return PredicateResult(
                status: Satisfiability.from(matches: result, style: style),
                message: failureMessage.toExpectationMessage
            )
        }
    }

    public static func fromBoolResult(_ matcher: @escaping (Expression<T>, FailureMessage) throws -> Bool) -> Predicate {
        return Predicate { actual, _ in
            let failureMessage = FailureMessage()
            let result = try matcher(actual, failureMessage)
            return PredicateResult(
                status: Satisfiability(bool: result),
                message: failureMessage.toExpectationMessage
            )
        }

    }

    public static func fromMatcher<M>(_ matcher: M) -> Predicate where M: Matcher, M.ValueType == T {
        return self.fromBoolResult(matcher.toClosure)
    }

    public func matches(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        let result = try satisfies(actualExpression, .ToMatch)
        result.message.update(failureMessage: failureMessage)
        return result.toBoolean(expectation: .ToMatch)
    }

    public func doesNotMatch(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        let result = try satisfies(actualExpression, .ToNotMatch)
        result.message.update(failureMessage: failureMessage)
        return result.toBoolean(expectation: .ToNotMatch)
    }
}

extension Predicate {
    // Someday, make this public? Needs documentation
    internal func after(f: @escaping (Expression<T>, ExpectationStyle, PredicateResult) throws -> PredicateResult) -> Predicate<T> {
        return Predicate { actual, style -> PredicateResult in
            let result = try self.satisfies(actual, style)
            return try f(actual, style, result)
        }
    }

    /// Returns a new Predicate based on the current one that always fails if nil is given as
    /// the actual value.
    ///
    /// This replaces `NonNilMatcherFunc`.
    public var requireNonNil: Predicate<T> {
        return after { actual, _, result in
            if try actual.evaluate() == nil {
                return PredicateResult(
                    status: .Fail,
                    message: .Append(result.message, " (use beNil() to match nils)")
                )
            }
            return result
        }
    }
}
