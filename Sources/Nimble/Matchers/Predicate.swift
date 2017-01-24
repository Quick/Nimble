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
    fileprivate var matcher: (Expression<T>, ExpectationStyle) throws -> PredicateResult

    /// Constructs a predicate that knows how take a given value
    public init(_ matcher: @escaping (Expression<T>, ExpectationStyle) throws -> PredicateResult) {
        self.matcher = matcher
    }

    public func satisfies(_ expression: Expression<T>, _ style: ExpectationStyle) throws -> PredicateResult {
        return try matcher(expression, style)
    }
}

public enum ExpectationStyle {
    case ToMatch, ToNotMatch
}

public indirect enum ExpectationMessage {
    /// includes actual value in output ("expected to <string>, got <actual>")
    case ExpectedActualValueTo(String)
    /// excludes actual value in output ("expected to <string>")
    case ExpectedTo(String)
    /// allows any free-form message ("<string>")
    case Fail(String)

    /// appends after an existing message ("<expectation> (use beNil() to match nils)")
    case Append(ExpectationMessage, String)
    /// provides long-form multi-line explainations ("<expectation>\n\n<string>")
    case Details(ExpectationMessage, String)

    func toString(actual: String, expected: String = "expected", to: String = "to") -> String {
        switch self {
        case let .Fail(msg):
            return msg
        case let .ExpectedTo(msg):
            return "\(expected) \(to) \(msg)"
        case let .ExpectedActualValueTo(msg):
            return "\(expected) \(to) \(msg), got \(actual)"
        case let .Append(expectation, msg):
            return "\(expectation.toString(actual: actual, expected: expected, to: to)) \(msg)"
        case let .Details(expectation, msg):
            return "\(expectation.toString(actual: actual, expected: expected, to: to))\n\n\(msg)"
        }
    }

    func update(failureMessage: FailureMessage) {
        switch self {
        case let .Fail(msg):
            failureMessage.stringValue = msg
        case let .ExpectedTo(msg):
            failureMessage.actualValue = nil
            failureMessage.postfixMessage = msg
        case let .ExpectedActualValueTo(msg):
            failureMessage.postfixMessage = msg
        case let .Append(expectation, msg):
            expectation.update(failureMessage: failureMessage)
            failureMessage.postfixActual = msg
        case let .Details(expectation, msg):
            expectation.update(failureMessage: failureMessage)
            if let desc = failureMessage.userDescription {
                failureMessage.userDescription = desc + msg
            }
        }
    }
}

extension FailureMessage {
    var toExpectationMessage: ExpectationMessage {
        return .Fail("TODO")
    }
}

public struct PredicateResult {
    let status: Satisfiability
    let message: ExpectationMessage

    public func toBoolean(expectation style: ExpectationStyle) -> Bool {
        return status.toBoolean(expectation: style)
    }
}

public enum Satisfiability {
    case Matches, DoesNotMatch, Fail

    static internal func from(matches: Bool, expectation style: ExpectationStyle) -> Satisfiability {
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
    public init(_ matcher: @escaping (Expression<T>, FailureMessage, Bool) throws -> Bool) {
        self.matcher = ({ actual, style in
            let failureMessage = FailureMessage()
            let result = try matcher(actual, failureMessage, style == .ToMatch)
            return PredicateResult(
                status: Satisfiability.from(matches: result, expectation: style),
                message: failureMessage.toExpectationMessage
            )
        })
    }

    public init(_ matcher: @escaping (Expression<T>, FailureMessage) throws -> Bool) {
        self.matcher = ({ actual, style in
            let failureMessage = FailureMessage()
            let result = try matcher(actual, failureMessage)
            return PredicateResult(
                status: Satisfiability.from(matches: result, expectation: style),
                message: failureMessage.toExpectationMessage
            )
        })

    }

    public init<M>(_ matcher: M) where M: Matcher, M.ValueType == T {
        self.init(matcher.toClosure)
    }

    public func matches(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        return try satisfies(actualExpression, .ToMatch).toBoolean(expectation: .ToMatch)
    }

    public func doesNotMatch(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        return try satisfies(actualExpression, .ToNotMatch).toBoolean(expectation: .ToNotMatch)
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
                    message: .Append(result.message, "(use beNil() to match nils)")
                )
            }
            return result
        }
    }
}
