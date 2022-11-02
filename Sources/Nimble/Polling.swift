#if !os(WASI)

import Foundation
import Dispatch

/// If you are running on a slower machine, it could be useful to increase the default timeout value
/// or slow down poll interval. Default timeout interval is 1, and poll interval is 0.01.
public struct AsyncDefaults {
    public static var timeout: DispatchTimeInterval = .seconds(1)
    public static var pollInterval: DispatchTimeInterval = .milliseconds(10)
}

internal enum AsyncMatchStyle {
    case eventually, never, always
}

// swiftlint:disable:next function_parameter_count
private func poll<T>(
    style: ExpectationStyle,
    matchStyle: AsyncMatchStyle,
    predicate: Predicate<T>,
    timeout: DispatchTimeInterval,
    poll: DispatchTimeInterval,
    fnName: String
) -> Predicate<T> {
    return Predicate { actualExpression in
        let uncachedExpression = actualExpression.withoutCaching()
        let fnName = "expect(...).\(fnName)(...)"
        var lastPredicateResult: PredicateResult?
        let result = pollBlock(
            pollInterval: poll,
            timeoutInterval: timeout,
            file: actualExpression.location.file,
            line: actualExpression.location.line,
            fnName: fnName) {
                lastPredicateResult = try predicate.satisfies(uncachedExpression)
                return lastPredicateResult!.toBoolean(expectation: style)
        }
        return processPollResult(result, matchStyle: matchStyle, lastPredicateResult: lastPredicateResult, fnName: fnName)
    }
}

// swiftlint:disable:next cyclomatic_complexity
internal func processPollResult(_ result: PollResult<Bool>, matchStyle: AsyncMatchStyle, lastPredicateResult: PredicateResult?, fnName: String) -> PredicateResult {
    switch result {
    case .completed:
        switch matchStyle {
        case .eventually:
            return lastPredicateResult!
        case .never:
            return PredicateResult(
                status: .fail,
                message: lastPredicateResult?.message ?? .fail("matched the predicate when it shouldn't have")
            )
        case .always:
            return PredicateResult(
                status: .fail,
                message: lastPredicateResult?.message ?? .fail("didn't match the predicate when it should have")
            )
        }
    case .timedOut:
        switch matchStyle {
        case .eventually:
            let message = lastPredicateResult?.message ?? .fail("timed out before returning a value")
            return PredicateResult(status: .fail, message: message)
        case .never:
            return PredicateResult(status: .doesNotMatch, message: .expectedTo("never match the predicate"))
        case .always:
            return PredicateResult(status: .matches, message: .expectedTo("always match the predicate"))
        }
    case let .errorThrown(error):
        return PredicateResult(status: .fail, message: .fail("unexpected error thrown: <\(error)>"))
    case let .raisedException(exception):
        return PredicateResult(status: .fail, message: .fail("unexpected exception raised: \(exception)"))
    case .blockedRunLoop:
        let message = lastPredicateResult?.message.appended(message: " (timed out, but main run loop was unresponsive).") ??
            .fail("main run loop was unresponsive")
        return PredicateResult(status: .fail, message: message)
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
    @available(*, noasync, message: "the sync version of `toEventually` does not work in async contexts. Use the async version with the same name as a drop-in replacement")
    public func toEventually(_ predicate: Predicate<Value>, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toMatch,
            poll(
                style: .toMatch,
                matchStyle: .eventually,
                predicate: predicate,
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
    @available(*, noasync, message: "the sync version of `toEventuallyNot` does not work in async contexts. Use the async version with the same name as a drop-in replacement")
    public func toEventuallyNot(_ predicate: Predicate<Value>, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toNotMatch,
            poll(
                style: .toNotMatch,
                matchStyle: .eventually,
                predicate: predicate,
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
    @available(*, noasync, message: "the sync version of `toNotEventually` does not work in async contexts. Use the async version with the same name as a drop-in replacement")
    public func toNotEventually(_ predicate: Predicate<Value>, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) -> Self {
        return toEventuallyNot(predicate, timeout: timeout, pollInterval: pollInterval, description: description)
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
    @available(*, noasync, message: "the sync version of `toNever` does not work in async contexts. Use the async version with the same name as a drop-in replacement")
    public func toNever(_ predicate: Predicate<Value>, until: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toNotMatch,
            poll(
                style: .toMatch,
                matchStyle: .never,
                predicate: predicate,
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
    @available(*, noasync, message: "the sync version of `neverTo` does not work in async contexts. Use the async version with the same name as a drop-in replacement")
    public func neverTo(_ predicate: Predicate<Value>, until: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) -> Self {
        return toNever(predicate, until: until, pollInterval: pollInterval, description: description)
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
    @available(*, noasync, message: "the sync version of `toAlways` does not work in async contexts. Use the async version with the same name as a drop-in replacement")
    public func toAlways(_ predicate: Predicate<Value>, until: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toMatch,
            poll(
                style: .toNotMatch,
                matchStyle: .always,
                predicate: predicate,
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
    @available(*, noasync, message: "the sync version of `alwaysTo` does not work in async contexts. Use the async version with the same name as a drop-in replacement")
    public func alwaysTo(_ predicate: Predicate<Value>, until: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) -> Self {
        return toAlways(predicate, until: until, pollInterval: pollInterval, description: description)
    }
}

#endif // #if !os(WASI)
