// New Matcher API
//

/// A Matcher is part of the new matcher API that provides assertions to expectations.
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
/// In the 2023 Apple Platform releases (macOS 14, iOS 17, watchOS 10, tvOS 17, visionOS 1), Apple
/// renamed `NSMatcher` to `Matcher`. In response, we decided to rename `Matcher` to
/// `Matcher`.
public struct Matcher<T> {
    fileprivate var matcher: (Expression<T>) throws -> MatcherResult

    /// Constructs a matcher that knows how take a given value
    public init(_ matcher: @escaping (Expression<T>) throws -> MatcherResult) {
        self.matcher = matcher
    }

    /// Uses a matcher on a given value to see if it passes the matcher.
    ///
    /// @param expression The value to run the matcher's logic against
    /// @returns A matcher result indicate passing or failing and an associated error message.
    public func satisfies(_ expression: Expression<T>) throws -> MatcherResult {
        return try matcher(expression)
    }
}

/// Provides an easy upgrade path for custom Matchers to be renamed to Matchers
@available(*, deprecated, renamed: "Matcher")
public typealias Predicate = Matcher

/// Provides convenience helpers to defining matchers
extension Matcher {
    /// Like Matcher() constructor, but automatically guard against nil (actual) values
    public static func define(matcher: @escaping (Expression<T>) throws -> MatcherResult) -> Matcher<T> {
        return Matcher<T> { actual in
            return try matcher(actual)
        }.requireNonNil
    }

    /// Defines a matcher with a default message that can be returned in the closure
    /// Also ensures the matcher's actual value cannot pass with `nil` given.
    public static func define(_ message: String = "match", matcher: @escaping (Expression<T>, ExpectationMessage) throws -> MatcherResult) -> Matcher<T> {
        return Matcher<T> { actual in
            return try matcher(actual, .expectedActualValueTo(message))
        }.requireNonNil
    }

    /// Defines a matcher with a default message that can be returned in the closure
    /// Unlike `define`, this allows nil values to succeed if the given closure chooses to.
    public static func defineNilable(_ message: String = "match", matcher: @escaping (Expression<T>, ExpectationMessage) throws -> MatcherResult) -> Matcher<T> {
        return Matcher<T> { actual in
            return try matcher(actual, .expectedActualValueTo(message))
        }
    }
}

extension Matcher {
    /// Provides a simple matcher definition that provides no control over the predefined
    /// error message.
    ///
    /// Also ensures the matcher's actual value cannot pass with `nil` given.
    public static func simple(_ message: String = "match", matcher: @escaping (Expression<T>) throws -> MatcherStatus) -> Matcher<T> {
        return Matcher<T> { actual in
            return MatcherResult(status: try matcher(actual), message: .expectedActualValueTo(message))
        }.requireNonNil
    }

    /// Provides a simple matcher definition that provides no control over the predefined
    /// error message.
    ///
    /// Unlike `simple`, this allows nil values to succeed if the given closure chooses to.
    public static func simpleNilable(_ message: String = "match", matcher: @escaping (Expression<T>) throws -> MatcherStatus) -> Matcher<T> {
        return Matcher<T> { actual in
            return MatcherResult(status: try matcher(actual), message: .expectedActualValueTo(message))
        }
    }
}

/// The Expectation style intended for comparison to a MatcherStatus.
public enum ExpectationStyle {
    case toMatch, toNotMatch
}

/// The value that a Matcher returns to describe if the given (actual) value matches the
/// matcher.
public struct MatcherResult {
    /// Status indicates if the matcher matches, does not match, or fails.
    public var status: MatcherStatus
    /// The error message that can be displayed if it does not match
    public var message: ExpectationMessage

    /// Constructs a new MatcherResult with a given status and error message
    public init(status: MatcherStatus, message: ExpectationMessage) {
        self.status = status
        self.message = message
    }

    /// Shorthand to MatcherResult(status: MatcherStatus(bool: bool), message: message)
    public init(bool: Bool, message: ExpectationMessage) {
        self.status = MatcherStatus(bool: bool)
        self.message = message
    }

    /// Converts the result to a boolean based on what the expectation intended
    public func toBoolean(expectation style: ExpectationStyle) -> Bool {
        return status.toBoolean(expectation: style)
    }
}

/// Provides an easy upgrade path for custom Matchers to be renamed to Matchers
@available(*, deprecated, renamed: "MatcherResult")
public typealias PredicateResult = MatcherResult

/// MatcherStatus is a trinary that indicates if a Matcher matches a given value or not
public enum MatcherStatus {
    /// Matches indicates if the matcher / matcher passes with the given value
    ///
    /// For example, `equals(1)` returns `.matches` for `expect(1).to(equal(1))`.
    case matches
    /// DoesNotMatch indicates if the matcher fails with the given value, but *would*
    /// succeed if the expectation was inverted.
    ///
    /// For example, `equals(2)` returns `.doesNotMatch` for `expect(1).toNot(equal(2))`.
    case doesNotMatch
    /// Fail indicates the matcher will never satisfy with the given value in any case.
    /// A perfect example is that most matchers fail whenever given `nil`.
    ///
    /// Using `equal(1)` fails both `expect(nil).to(equal(1))` and `expect(nil).toNot(equal(1))`.
    /// Note: Matcher's `requireNonNil` property will also provide this feature mostly for free.
    ///       Your matcher will still need to guard against nils, but error messaging will be
    ///       handled for you.
    case fail

    /// Converts a boolean to either .matches (if true) or .doesNotMatch (if false).
    public init(bool matches: Bool) {
        if matches {
            self = .matches
        } else {
            self = .doesNotMatch
        }
    }

    private func shouldMatch() -> Bool {
        switch self {
        case .matches: return true
        case .doesNotMatch, .fail: return false
        }
    }

    private func shouldNotMatch() -> Bool {
        switch self {
        case .doesNotMatch: return true
        case .matches, .fail: return false
        }
    }

    /// Converts the MatcherStatus result to a boolean based on what the expectation intended
    internal func toBoolean(expectation style: ExpectationStyle) -> Bool {
        if style == .toMatch {
            return shouldMatch()
        } else {
            return shouldNotMatch()
        }
    }
}

/// Provides an easy upgrade path for custom Matchers to be renamed to Matchers
@available(*, deprecated, renamed: "MatcherStatus")
public typealias PredicateStatus = MatcherStatus

extension Matcher {
    // Someday, make this public? Needs documentation
    internal func after(f: @escaping (Expression<T>, MatcherResult) throws -> MatcherResult) -> Matcher<T> {
        // swiftlint:disable:previous identifier_name
        return Matcher { actual -> MatcherResult in
            let result = try self.satisfies(actual)
            return try f(actual, result)
        }
    }

    /// Returns a new Matcher based on the current one that always fails if nil is given as
    /// the actual value.
    public var requireNonNil: Matcher<T> {
        return after { actual, result in
            if try actual.evaluate() == nil {
                return MatcherResult(
                    status: .fail,
                    message: result.message.appendedBeNilHint()
                )
            }
            return result
        }
    }
}

#if canImport(Darwin)
import class Foundation.NSObject

public typealias MatcherBlock = (_ actualExpression: Expression<NSObject>) throws -> NMBMatcherResult

/// Provides an easy upgrade path for custom Matchers to be renamed to Matchers
@available(*, deprecated, renamed: "MatcherBlock")
public typealias PredicateBlock = MatcherBlock

public class NMBMatcher: NSObject {
    private let matcher: MatcherBlock

    public init(matcher: @escaping MatcherBlock) {
        self.matcher = matcher
    }

    @available(*, deprecated, renamed: "init(matcher:)")
    public convenience init(predicate: @escaping MatcherBlock) {
        self.init(matcher: predicate)
    }

    func satisfies(_ expression: @escaping () throws -> NSObject?, location: SourceLocation) -> NMBMatcherResult {
        let expr = Expression(expression: expression, location: location)
        do {
            return try self.matcher(expr)
        } catch let error {
            return MatcherResult(status: .fail, message: .fail("unexpected error thrown: <\(error)>")).toObjectiveC()
        }
    }
}

/// Provides an easy upgrade path for custom Matchers to be renamed to Matchers
@available(*, deprecated, renamed: "NMBMatcher")
public typealias NMBPredicate = NMBMatcher

final public class NMBMatcherResult: NSObject {
    public var status: NMBMatcherStatus
    public var message: NMBExpectationMessage

    public init(status: NMBMatcherStatus, message: NMBExpectationMessage) {
        self.status = status
        self.message = message
    }

    public init(bool success: Bool, message: NMBExpectationMessage) {
        self.status = NMBMatcherStatus.from(bool: success)
        self.message = message
    }

    public func toSwift() -> MatcherResult {
        return MatcherResult(status: status.toSwift(),
                               message: message.toSwift())
    }
}

/// Provides an easy upgrade path for custom Matchers to be renamed to Matchers
@available(*, deprecated, renamed: "NMBMatcherResult")
public typealias NMBPredicateResult = NMBMatcherResult

extension MatcherResult {
    public func toObjectiveC() -> NMBMatcherResult {
        return NMBMatcherResult(status: status.toObjectiveC(), message: message.toObjectiveC())
    }
}

final public class NMBMatcherStatus: NSObject {
    private let status: Int
    private init(status: Int) {
        self.status = status
    }

    public static let matches: NMBMatcherStatus = NMBMatcherStatus(status: 0)
    public static let doesNotMatch: NMBMatcherStatus = NMBMatcherStatus(status: 1)
    public static let fail: NMBMatcherStatus = NMBMatcherStatus(status: 2)

    public override var hash: Int { return self.status.hashValue }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherMatcher = object as? NMBMatcherStatus else {
            return false
        }
        return self.status == otherMatcher.status
    }

    public static func from(status: MatcherStatus) -> NMBMatcherStatus {
        switch status {
        case .matches: return self.matches
        case .doesNotMatch: return self.doesNotMatch
        case .fail: return self.fail
        }
    }

    public static func from(bool success: Bool) -> NMBMatcherStatus {
        return self.from(status: MatcherStatus(bool: success))
    }

    public func toSwift() -> MatcherStatus {
        switch status {
        case NMBMatcherStatus.matches.status: return .matches
        case NMBMatcherStatus.doesNotMatch.status: return .doesNotMatch
        case NMBMatcherStatus.fail.status: return .fail
        default:
            internalError("Unhandle status for NMBMatcherStatus")
        }
    }
}

/// Provides an easy upgrade path for custom Matchers to be renamed to Matchers
@available(*, deprecated, renamed: "NMBMatcherStatus")
public typealias NMBPredicateStatus = NMBMatcherStatus

extension MatcherStatus {
    public func toObjectiveC() -> NMBMatcherStatus {
        return NMBMatcherStatus.from(status: self)
    }
}

#endif
