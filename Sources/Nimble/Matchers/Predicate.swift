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
}

public enum ExpectationStyle {
    case ToMatch, ToNotMatch
}

public indirect enum ExpectationMessage {
    /// includes actual value in output ("expected to <string>, got <actual>")
    case ExpectedValueTo(/* message: */ String, /* actual: */ String)
    /// includes actual value in output ("expected to <string>, got <actual>")
    case ExpectedActualValueTo(/* message: */ String)
    /// excludes actual value in output ("expected to <string>")
    case ExpectedTo(/* message: */ String)
    /// allows any free-form message ("<string>")
    case Fail(/* message: */ String)

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
        case let .ExpectedValueTo(msg, actual):
            return "\(expected) \(to) \(msg), got \(actual)"
        case let .Append(expectation, msg):
            return "\(expectation.toString(actual: actual, expected: expected, to: to))\(msg)"
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
        case let .ExpectedValueTo(msg, actual):
            failureMessage.postfixMessage = msg
            failureMessage.actualValue = actual
        case let .Append(expectation, msg):
            expectation.update(failureMessage: failureMessage)
            failureMessage.postfixActual += msg
        case let .Details(expectation, msg):
            expectation.update(failureMessage: failureMessage)
            if let desc = failureMessage.userDescription {
                failureMessage.userDescription = desc
            }
            failureMessage.extendedMessage = msg
        }
    }
}

extension FailureMessage {
    var toExpectationMessage: ExpectationMessage {
        let defaultMsg = FailureMessage()
        if expected != defaultMsg.expected || _stringValueOverride != nil {
            return .Fail(stringValue)
        }

        var msg: ExpectationMessage = .Fail(userDescription ?? "")
        if actualValue != "" && actualValue != nil {
            msg = .ExpectedValueTo(postfixMessage, actualValue ?? "")
        } else if postfixMessage != defaultMsg.postfixMessage {
            if actualValue == nil {
                msg = .ExpectedTo(postfixMessage)
            } else {
                msg = .ExpectedActualValueTo(postfixMessage)
            }
        }
        if postfixActual != defaultMsg.postfixActual {
            msg = .Append(msg, postfixActual)
        }
        if let m = extendedMessage {
            msg = .Details(msg, m)
        }
        return msg
    }
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
