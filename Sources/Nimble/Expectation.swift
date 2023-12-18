internal func execute<T>(_ expression: Expression<T>, _ style: ExpectationStyle, _ matcher: Matcher<T>, to: String, description: String?, captureExceptions: Bool = true) -> (Bool, FailureMessage) {
    func run() -> (Bool, FailureMessage) {
        let msg = FailureMessage()
        msg.userDescription = description
        msg.to = to
        do {
            let result = try matcher.satisfies(expression)
            result.message.update(failureMessage: msg)
            if msg.actualValue == "" {
                msg.actualValue = "<\(stringify(try expression.evaluate()))>"
            }
            return (result.toBoolean(expectation: style), msg)
        } catch let error {
            msg.stringValue = "unexpected error thrown: <\(error)>"
            return (false, msg)
        }
    }

    var result: (Bool, FailureMessage) = (false, FailureMessage())
    if captureExceptions {
        let capture = NMBExceptionCapture(handler: ({ exception -> Void in
            let msg = FailureMessage()
            msg.stringValue = "unexpected exception raised: \(exception)"
            result = (false, msg)
        }), finally: nil)
        capture.tryBlock {
            result = run()
        }
    } else {
        result = run()
    }

    return result
}

internal func execute<T>(_ expression: AsyncExpression<T>, _ style: ExpectationStyle, _ matcher: AsyncMatcher<T>, to: String, description: String?) async -> (Bool, FailureMessage) {
    let msg = FailureMessage()
    msg.userDescription = description
    msg.to = to
    do {
        let result = try await matcher.satisfies(expression)
        result.message.update(failureMessage: msg)
        if msg.actualValue == "" {
            msg.actualValue = "<\(stringify(try await expression.evaluate()))>"
        }
        return (result.toBoolean(expectation: style), msg)
    } catch let error {
        msg.stringValue = "unexpected error thrown: <\(error)>"
        return (false, msg)
    }
}

public enum ExpectationStatus: Equatable {

    /// No matchers have been performed.
    case pending

    /// All matchers have passed.
    case passed

    /// All matchers have failed.
    case failed

    /// Multiple matchers have been peformed, with at least one passing and one failing.
    case mixed
}

extension ExpectationStatus {
    /// Applies a new status to the current one to produce a combined status.
    ///
    /// This method is meant to advance the state from `.pending` to either `.passed` or`.failed`.
    /// When called multiple times with different values, the result will be `.mixed`.
    /// E.g., `status.applying(.passed).applying(.failed) == .mixed`.
    func applying(_ newerStatus: ExpectationStatus) -> ExpectationStatus {
        if newerStatus == .pending { return self }
        if self == .pending || self == newerStatus { return newerStatus }
        return .mixed
    }
}

public protocol Expectation {
    var location: SourceLocation { get }

    /// The status of the test after matchers have been evaluated.
    ///
    /// This property can be used for changing test behavior based whether an expectation has
    /// passed.
    ///
    /// In the below example, we perform additional tests on an array only if it has enough
    /// elements.
    ///
    /// ```
    /// if expect(array).to(haveCount(10)).status == .passed {
    ///    expect(array[9]).to(...)
    /// }
    /// ```
    ///
    /// - Remark: Similar functionality can be achieved using the `onFailure(throw:)` method.
    var status: ExpectationStatus { get }

    /// Takes the result of a test and passes it to the assertion handler.
    ///
    /// - Returns: An updated `Expression` with the result of the test applied to the `status`
    ///            property.
    @discardableResult
    func verify(_ pass: Bool, _ message: FailureMessage) -> Self
}

extension Expectation {
    /// Throws the supplied error if the expectation has previously failed.
    ///
    /// This provides a mechanism for halting tests when a failure occurs.  This can be used in
    /// conjunction with `Quick.StopTest` to halt a test when a failure would cause subsequent test
    /// code to fail.
    ///
    /// In the below example, the test will stop in the first line if `array.count == 5` rather
    /// than crash on the second line.
    ///
    /// ```
    /// try expect(array).to(haveCount(10)).onFailure(throw: StopTest.silently)
    /// expect(array[9]).to(...)
    /// ```
    ///
    /// - Warning: This method **MUST** be called after a matcher method like `to` or `not`.
    ///            Otherwise, this expectation will be in an indeterminate state and will
    ///            unconditionally log an error.
    ///
    /// - Remark: Similar functionality can be achieved using the `status` property.
    /// - Attention: This is deprecated in favor of the `require` dsl (``require``, ``unwrap``,
    ///              ``pollUnwrap``), which integrates the matcher seemlessly, or, in the case of
    ///              `unwrap` and `pollUnwrap`, acts as a shorthand when you require that an
    ///              expression evaluate to some non-nil value. `onFailure` will be removed in
    ///              Nimble 15.
    @available(*, deprecated, message: "Use the require dsl")
    public func onFailure(`throw` error: Error) throws {
        switch status {
        case .pending:
            let msg = """
                Attempted to call `Expectation.onFailure(throw:) before a matcher has been applied.
                Try using `expect(...).to(...).onFailure(throw: ...`) instead.
                """

            let handler = NimbleEnvironment.activeInstance.assertionHandler
            handler.assert(false, message: .init(stringValue: msg), location: location)
        case .passed:
            break
        case .failed, .mixed:
            throw error
        }
    }
}

public struct SyncExpectation<Value>: Expectation {
    public let expression: Expression<Value>

    /// The status of the test after matchers have been evaluated.
    ///
    /// This property can be used for changing test behavior based whether an expectation has
    /// passed.
    ///
    /// In the below example, we perform additional tests on an array only if it has enough
    /// elements.
    ///
    /// ```
    /// if expect(array).to(haveCount(10)).status == .passed {
    ///    expect(array[9]).to(...)
    /// }
    /// ```
    ///
    /// - Remark: Similar functionality can be achieved using the `onFailure(throw:)` method.
    public let status: ExpectationStatus

    private init(expression: Expression<Value>, status: ExpectationStatus) {
        self.expression = expression
        self.status = status
    }

    public init(expression: Expression<Value>) {
        self.init(expression: expression, status: .pending)
    }

    /// Takes the result of a test and passes it to the assertion handler.
    ///
    /// - Returns: An updated `Expression` with the result of the test applied to the `status`
    ///            property.
    @discardableResult
    public func verify(_ pass: Bool, _ message: FailureMessage) -> Self {
        let handler = NimbleEnvironment.activeInstance.assertionHandler
        handler.assert(pass, message: message, location: expression.location)

        return .init(expression: expression, status: status.applying(pass ? .passed : .failed))
    }

    public var location: SourceLocation { expression.location }

    /// Tests the actual value using a matcher to match.
    @discardableResult
    public func to(_ matcher: Matcher<Value>, description: String? = nil) -> Self {
        let (pass, msg) = execute(expression, .toMatch, matcher, to: "to", description: description)
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    @discardableResult
    public func toNot(_ matcher: Matcher<Value>, description: String? = nil) -> Self {
        let (pass, msg) = execute(expression, .toNotMatch, matcher, to: "to not", description: description)
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    @discardableResult
    public func notTo(_ matcher: Matcher<Value>, description: String? = nil) -> Self {
        toNot(matcher, description: description)
    }

    // MARK: - AsyncMatchers
    /// Tests the actual value using a matcher to match.
    @discardableResult
    public func to(_ matcher: AsyncMatcher<Value>, description: String? = nil) async -> Self {
        let (pass, msg) = await execute(expression.toAsyncExpression(), .toMatch, matcher, to: "to", description: description)
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    @discardableResult
    public func toNot(_ matcher: AsyncMatcher<Value>, description: String? = nil) async -> Self {
        let (pass, msg) = await execute(expression.toAsyncExpression(), .toNotMatch, matcher, to: "to not", description: description)
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    @discardableResult
    public func notTo(_ matcher: AsyncMatcher<Value>, description: String? = nil) async -> Self {
        await toNot(matcher, description: description)
    }

    // see:
    // - `Polling.swift` for toEventually and older-style polling-based approach to "async"
    // - NMBExpectation for Objective-C interface
}

public struct AsyncExpectation<Value>: Expectation {
    public let expression: AsyncExpression<Value>

    /// The status of the test after matchers have been evaluated.
    ///
    /// This property can be used for changing test behavior based whether an expectation has
    /// passed.
    ///
    /// In the below example, we perform additional tests on an array only if it has enough
    /// elements.
    ///
    /// ```
    /// if expect(array).to(haveCount(10)).status == .passed {
    ///    expect(array[9]).to(...)
    /// }
    /// ```
    ///
    /// - Remark: Similar functionality can be achieved using the `onFailure(throw:)` method.
    public let status: ExpectationStatus

    private init(expression: AsyncExpression<Value>, status: ExpectationStatus) {
        self.expression = expression
        self.status = status
    }

    public init(expression: AsyncExpression<Value>) {
        self.init(expression: expression, status: .pending)
    }

    public var location: SourceLocation { expression.location }

    /// Takes the result of a test and passes it to the assertion handler.
    ///
    /// - Returns: An updated `Expression` with the result of the test applied to the `status`
    ///            property.
    @discardableResult
    public func verify(_ pass: Bool, _ message: FailureMessage) -> Self {
        let handler = NimbleEnvironment.activeInstance.assertionHandler
        handler.assert(pass, message: message, location: expression.location)

        return .init(expression: expression, status: status.applying(pass ? .passed : .failed))
    }

    /// Tests the actual value using a matcher to match.
    @discardableResult
    public func to(_ matcher: Matcher<Value>, description: String? = nil) async -> Self {
        let (pass, msg) = execute(await expression.toSynchronousExpression(), .toMatch, matcher, to: "to", description: description)
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    @discardableResult
    public func toNot(_ matcher: Matcher<Value>, description: String? = nil) async -> Self {
        let (pass, msg) = execute(await expression.toSynchronousExpression(), .toNotMatch, matcher, to: "to not", description: description)
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    @discardableResult
    public func notTo(_ matcher: Matcher<Value>, description: String? = nil) async -> Self {
        await toNot(matcher, description: description)
    }

    /// Tests the actual value using a matcher to match.
    @discardableResult
    public func to(_ matcher: AsyncMatcher<Value>, description: String? = nil) async -> Self {
        let (pass, msg) = await execute(expression, .toMatch, matcher, to: "to", description: description)
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    @discardableResult
    public func toNot(_ matcher: AsyncMatcher<Value>, description: String? = nil) async -> Self {
        let (pass, msg) = await execute(expression, .toNotMatch, matcher, to: "to not", description: description)
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    @discardableResult
    public func notTo(_ matcher: AsyncMatcher<Value>, description: String? = nil) async -> Self {
        await toNot(matcher, description: description)
    }
}
