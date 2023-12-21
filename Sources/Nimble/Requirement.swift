import Foundation

public struct RequireError: Error, CustomNSError {
    let message: String
    let location: SourceLocation

    var localizedDescription: String { message }
    public var errorUserInfo: [String: Any] {
        // Required to prevent Xcode from reporting that we threw an error.
        // The default assertionHandlers will report this to XCode for us.
        ["XCTestErrorUserInfoKeyShouldIgnore": true]
    }

    static func unknown(_ location: SourceLocation) -> RequireError {
        RequireError(message: "Nimble error - file a bug if you see this!", location: location)
    }
}
internal func executeRequire<T>(_ expression: Expression<T>, _ style: ExpectationStyle, _ matcher: Matcher<T>, to: String, description: String?, captureExceptions: Bool = true) -> (Bool, FailureMessage, T?) {
    func run() -> (Bool, FailureMessage, T?) {
        let msg = FailureMessage()
        msg.userDescription = description
        msg.to = to
        do {
            let cachedExpression = expression.withCaching()
            let result = try matcher.satisfies(cachedExpression)
            let value = try cachedExpression.evaluate()
            result.message.update(failureMessage: msg)
            if msg.actualValue == "" {
                msg.actualValue = "<\(stringify(value))>"
            }
            return (result.toBoolean(expectation: style), msg, value)
        } catch let error {
            msg.stringValue = "unexpected error thrown: <\(error)>"
            return (false, msg, nil)
        }
    }

    var result: (Bool, FailureMessage, T?) = (false, FailureMessage(), nil)
    if captureExceptions {
        let capture = NMBExceptionCapture(handler: ({ exception -> Void in
            let msg = FailureMessage()
            msg.stringValue = "unexpected exception raised: \(exception)"
            result = (false, msg, nil)
        }), finally: nil)
        capture.tryBlock {
            result = run()
        }
    } else {
        result = run()
    }

    return result
}

internal func executeRequire<T>(_ expression: AsyncExpression<T>, _ style: ExpectationStyle, _ matcher: AsyncMatcher<T>, to: String, description: String?) async -> (Bool, FailureMessage, T?) {
    let msg = FailureMessage()
    msg.userDescription = description
    msg.to = to
    do {
        let cachedExpression = expression.withCaching()
        let result = try await matcher.satisfies(cachedExpression)
        let value = try await cachedExpression.evaluate()
        result.message.update(failureMessage: msg)
        if msg.actualValue == "" {
            msg.actualValue = "<\(stringify(value))>"
        }
        return (result.toBoolean(expectation: style), msg, value)
    } catch let error {
        msg.stringValue = "unexpected error thrown: <\(error)>"
        return (false, msg, nil)
    }
}

public struct SyncRequirement<Value> {
    public let expression: Expression<Value>

    /// A custom error to throw.
    /// If nil, then we will throw a ``RequireError`` on failure.
    public let customError: Error?

    public var location: SourceLocation { expression.location }

    public init(expression: Expression<Value>, customError: Error?) {
        self.expression = expression
        self.customError = customError
    }

    public func verify(_ pass: Bool, _ message: FailureMessage, _ value: Value?) throws -> Value {
        let handler = NimbleEnvironment.activeInstance.assertionHandler
        handler.assert(pass, message: message, location: expression.location)
        guard pass, let value else {
            throw customError ?? RequireError(message: message.stringValue, location: self.location)
        }
        return value
    }

    /// Tests the actual value using a matcher to match.
    @discardableResult
    public func to(_ matcher: Matcher<Value>, description: String? = nil) throws -> Value {
        let (pass, msg, result) = executeRequire(expression, .toMatch, matcher, to: "to", description: description)
        return try verify(pass, msg, result)
    }

    /// Tests the actual value using a matcher to not match.
    @discardableResult
    public func toNot(_ matcher: Matcher<Value>, description: String? = nil) throws -> Value {
        let (pass, msg, result) = executeRequire(expression, .toNotMatch, matcher, to: "to not", description: description)
        return try verify(pass, msg, result)
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    @discardableResult
    public func notTo(_ matcher: Matcher<Value>, description: String? = nil) throws -> Value {
        try toNot(matcher, description: description)
    }

    // MARK: - AsyncMatchers
    /// Tests the actual value using a matcher to match.
    @discardableResult
    public func to(_ matcher: AsyncMatcher<Value>, description: String? = nil) async throws -> Value {
        let (pass, msg, result) = await executeRequire(expression.toAsyncExpression(), .toMatch, matcher, to: "to", description: description)
        return try verify(pass, msg, result)
    }

    /// Tests the actual value using a matcher to not match.
    @discardableResult
    public func toNot(_ matcher: AsyncMatcher<Value>, description: String? = nil) async throws -> Value {
        let (pass, msg, result) = await executeRequire(expression.toAsyncExpression(), .toNotMatch, matcher, to: "to not", description: description)
        return try verify(pass, msg, result)
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    @discardableResult
    public func notTo(_ matcher: AsyncMatcher<Value>, description: String? = nil) async throws -> Value {
        try await toNot(matcher, description: description)
    }
}

public struct AsyncRequirement<Value> {
    public let expression: AsyncExpression<Value>

    /// A custom error to throw.
    /// If nil, then we will throw a ``RequireError`` on failure.
    public let customError: Error?

    public var location: SourceLocation { expression.location }

    public init(expression: AsyncExpression<Value>, customError: Error?) {
        self.expression = expression
        self.customError = customError
    }

    public func verify(_ pass: Bool, _ message: FailureMessage, _ value: Value?) throws -> Value {
        let handler = NimbleEnvironment.activeInstance.assertionHandler
        handler.assert(pass, message: message, location: expression.location)
        guard pass, let value else {
            throw customError ?? RequireError(message: message.stringValue, location: self.location)
        }
        return value
    }

    /// Tests the actual value using a matcher to match.
    @discardableResult
    public func to(_ matcher: Matcher<Value>, description: String? = nil) async throws -> Value {
        let (pass, msg, result) = executeRequire(await expression.toSynchronousExpression(), .toMatch, matcher, to: "to", description: description)
        return try verify(pass, msg, result)
    }

    /// Tests the actual value using a matcher to not match.
    @discardableResult
    public func toNot(_ matcher: Matcher<Value>, description: String? = nil) async throws -> Value {
        let (pass, msg, result) = executeRequire(await expression.toSynchronousExpression(), .toNotMatch, matcher, to: "to not", description: description)
        return try verify(pass, msg, result)
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    @discardableResult
    public func notTo(_ matcher: Matcher<Value>, description: String? = nil) async throws -> Value {
        try await toNot(matcher, description: description)
    }

    // MARK: - AsyncMatchers
    /// Tests the actual value using a matcher to match.
    @discardableResult
    public func to(_ matcher: AsyncMatcher<Value>, description: String? = nil) async throws -> Value {
        let (pass, msg, result) = await executeRequire(expression, .toMatch, matcher, to: "to", description: description)
        return try verify(pass, msg, result)
    }

    /// Tests the actual value using a matcher to not match.
    @discardableResult
    public func toNot(_ matcher: AsyncMatcher<Value>, description: String? = nil) async throws -> Value {
        let (pass, msg, result) = await executeRequire(expression, .toNotMatch, matcher, to: "to not", description: description)
        return try verify(pass, msg, result)
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    @discardableResult
    public func notTo(_ matcher: AsyncMatcher<Value>, description: String? = nil) async throws -> Value {
        try await toNot(matcher, description: description)
    }
}
