#if !os(WASI)

import Foundation
import Dispatch

/// If you are running on a slower machine, it could be useful to increase the default timeout value
/// or slow down poll interval. Default timeout interval is 1, and poll interval is 0.01.
///
/// - Warning: This has been renamed to ``PollingDefaults``. Starting in Nimble 14, `AsyncDefaults` will be removed entirely.
///
/// For the time being, `AsyncDefaults` will function the same.
/// However, `AsyncDefaults` will be removed in a future release.
@available(*, unavailable, renamed: "PollingDefaults")
public struct AsyncDefaults {
    public static var timeout: NimbleTimeInterval {
        get {
            PollingDefaults.timeout
        }
        set {
            PollingDefaults.timeout = newValue
        }
    }
    public static var pollInterval: NimbleTimeInterval {
        get {
            PollingDefaults.pollInterval
        }
        set {
            PollingDefaults.pollInterval = newValue
        }
    }
}

/// If you are running on a slower machine, it could be useful to increase the default timeout value
/// or slow down poll interval. Default timeout interval is 1, and poll interval is 0.01.
///
/// - Note: This used to be known as ``AsyncDefaults``.
public struct PollingDefaults: @unchecked Sendable {
    private static let lock = NSRecursiveLock()

    private static var _timeout: NimbleTimeInterval = .seconds(1)
    private static var _pollInterval: NimbleTimeInterval = .milliseconds(10)

    public static var timeout: NimbleTimeInterval {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _timeout
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _timeout = newValue
        }
    }
    public static var pollInterval: NimbleTimeInterval {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _pollInterval
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _pollInterval = newValue
        }
    }
}

internal enum AsyncMatchStyle {
    case eventually, never, always

    var isContinous: Bool {
        switch self {
        case .eventually:
            return false
        case .never, .always:
            return true
        }
    }
}

// swiftlint:disable:next function_parameter_count
internal func poll<T>(
    style: ExpectationStyle,
    matchStyle: AsyncMatchStyle,
    matcher: Matcher<T>,
    timeout: NimbleTimeInterval,
    poll: NimbleTimeInterval,
    fnName: String
) -> Matcher<T> {
    return Matcher { actualExpression in
        let uncachedExpression = actualExpression.withoutCaching()
        let fnName = "expect(...).\(fnName)(...)"
        var lastMatcherResult: MatcherResult?
        let result = pollBlock(
            pollInterval: poll,
            timeoutInterval: timeout,
            file: actualExpression.location.file,
            line: actualExpression.location.line,
            fnName: fnName) {
                lastMatcherResult = try matcher.satisfies(uncachedExpression)
                if lastMatcherResult!.toBoolean(expectation: style) {
                    if matchStyle.isContinous {
                        return .incomplete
                    }
                    return .finished(true)
                } else {
                    if matchStyle.isContinous {
                        return .finished(false)
                    } else {
                        return .incomplete
                    }
                }
        }
        return processPollResult(result, matchStyle: matchStyle, lastMatcherResult: lastMatcherResult, fnName: fnName)
    }
}

// swiftlint:disable:next cyclomatic_complexity
internal func processPollResult(_ result: PollResult<Bool>, matchStyle: AsyncMatchStyle, lastMatcherResult: MatcherResult?, fnName: String) -> MatcherResult {
    switch result {
    case .completed:
        switch matchStyle {
        case .eventually:
            return lastMatcherResult!
        case .never:
            return MatcherResult(
                status: .fail,
                message: lastMatcherResult?.message ?? .fail("matched the matcher when it shouldn't have")
            )
        case .always:
            return MatcherResult(
                status: .fail,
                message: lastMatcherResult?.message ?? .fail("didn't match the matcher when it should have")
            )
        }
    case .timedOut:
        switch matchStyle {
        case .eventually:
            let message = lastMatcherResult?.message ?? .fail("timed out before returning a value")
            return MatcherResult(status: .fail, message: message)
        case .never:
            return MatcherResult(status: .doesNotMatch, message: .expectedTo("never match the matcher"))
        case .always:
            return MatcherResult(status: .matches, message: .expectedTo("always match the matcher"))
        }
    case let .errorThrown(error):
        return MatcherResult(status: .fail, message: .fail("unexpected error thrown: <\(error)>"))
    case let .raisedException(exception):
        return MatcherResult(status: .fail, message: .fail("unexpected exception raised: \(exception)"))
    case .blockedRunLoop:
        let message = lastMatcherResult?.message.appended(message: " (timed out, but main run loop was unresponsive).") ??
            .fail("main run loop was unresponsive")
        return MatcherResult(status: .fail, message: message)
    case .incomplete:
        internalError("Reached .incomplete state for \(fnName)(...).")
    }
}

internal let toEventuallyRequiresClosureError = FailureMessage(
    stringValue: """
        expect(...).toEventually(...) requires an explicit closure (eg - expect { ... }.toEventually(...) )
        Swift 1.2 @autoclosure behavior has changed in an incompatible way for Nimble to function
        """
)

extension SyncExpectation {
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `toEventually` does not work in any kind of async context. Use the async form of `toEventually` if you are running tests in an async context.
    @discardableResult
    @available(*, noasync, message: "the sync variant of `toEventually` does not work in async contexts. Use the async variant as a drop-in replacement")
    public func toEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toMatch,
            poll(
                style: .toMatch,
                matchStyle: .eventually,
                matcher: matcher,
                timeout: timeout,
                poll: pollInterval,
                fnName: "toEventually"
            ),
            to: "to eventually",
            description: description,
            captureExceptions: false
        )
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `toEventuallyNot` does not work in any kind of async context.
    /// Use the async form of `toEventuallyNot` if you are running tests in an async context.
    @discardableResult
    @available(*, noasync, message: "the sync variant of `toEventuallyNot` does not work in async contexts. Use the async variant as a drop-in replacement")
    public func toEventuallyNot(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toNotMatch,
            poll(
                style: .toNotMatch,
                matchStyle: .eventually,
                matcher: matcher,
                timeout: timeout,
                poll: pollInterval,
                fnName: "toEventuallyNot"
            ),
            to: "to eventually not",
            description: description,
            captureExceptions: false
        )
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `toNotEventually` does not work in any kind of async context.
    /// Use the async form of `toNotEventually` if you are running tests in an async context.
    @discardableResult
    @available(*, noasync, message: "the sync variant of `toNotEventually` does not work in async contexts. Use the async variant as a drop-in replacement")
    public func toNotEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) -> Self {
        return toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `toNever` does not work in any kind of async context.
    /// Use the async form of `toNever` if you are running tests in an async context.
    @discardableResult
    @available(*, noasync, message: "the sync variant of `toNever` does not work in async contexts. Use the async variant as a drop-in replacement")
    public func toNever(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toNotMatch,
            poll(
                style: .toNotMatch,
                matchStyle: .never,
                matcher: matcher,
                timeout: until,
                poll: pollInterval,
                fnName: "toNever"
            ),
            to: "to never",
            description: description,
            captureExceptions: false
        )
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `neverTo` does not work in any kind of async context.
    /// Use the async form of `neverTo` if you are running tests in an async context.
    @discardableResult
    @available(*, noasync, message: "the sync variant of `neverTo` does not work in async contexts. Use the async variant as a drop-in replacement")
    public func neverTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) -> Self {
        return toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `toAlways` does not work in any kind of async context.
    /// Use the async form of `toAlways` if you are running tests in an async context.
    @discardableResult
    @available(*, noasync, message: "the sync variant of `toAlways` does not work in async contexts. Use the async variant as a drop-in replacement")
    public func toAlways(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toMatch,
            poll(
                style: .toMatch,
                matchStyle: .always,
                matcher: matcher,
                timeout: until,
                poll: pollInterval,
                fnName: "toAlways"
            ),
            to: "to always",
            description: description,
            captureExceptions: false
        )
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `alwaysTo` does not work in any kind of async context.
    /// Use the async form of `alwaysTo` if you are running tests in an async context.
    @discardableResult
    @available(*, noasync, message: "the sync variant of `alwaysTo` does not work in async contexts. Use the async variant as a drop-in replacement")
    public func alwaysTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) -> Self {
        return toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }
}

#endif // #if !os(WASI)
