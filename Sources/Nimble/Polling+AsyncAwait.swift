// swiftlint:disable file_length
#if !os(WASI)

import Dispatch

@MainActor
internal func execute<T>(_ expression: AsyncExpression<T>, style: ExpectationStyle, to: String, description: String?, matcherExecutor: () async throws -> MatcherResult) async -> (Bool, FailureMessage) {
    let msg = FailureMessage()
    msg.userDescription = description
    msg.to = to
    do {
        let result = try await matcherExecutor()
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

internal actor Poller<T> {
    private var lastMatcherResult: MatcherResult?

    init() {}

    // swiftlint:disable:next function_parameter_count
    func poll(expression: AsyncExpression<T>,
              style: ExpectationStyle,
              matchStyle: AsyncMatchStyle,
              timeout: NimbleTimeInterval,
              poll: NimbleTimeInterval,
              fnName: String,
              matcherRunner: @escaping () async throws -> MatcherResult) async -> MatcherResult {
        let fnName = "expect(...).\(fnName)(...)"
        let result = await pollBlock(
            pollInterval: poll,
            timeoutInterval: timeout,
            sourceLocation: expression.location,
            fnName: fnName) {
                if self.updateMatcherResult(result: try await matcherRunner())
                    .toBoolean(expectation: style) {
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
        return processPollResult(result.toPollResult(), matchStyle: matchStyle, lastMatcherResult: lastMatcherResult, fnName: fnName)
    }

    func updateMatcherResult(result: MatcherResult) -> MatcherResult {
        self.lastMatcherResult = result
        return result
    }
}

// swiftlint:disable:next function_parameter_count
internal func poll<T>(
    expression: AsyncExpression<T>,
    style: ExpectationStyle,
    matchStyle: AsyncMatchStyle,
    timeout: NimbleTimeInterval,
    poll: NimbleTimeInterval,
    fnName: String,
    matcherRunner: @escaping () async throws -> MatcherResult
) async -> MatcherResult {
    let poller = Poller<T>()
    return await poller.poll(
        expression: expression,
        style: style,
        matchStyle: matchStyle,
        timeout: timeout,
        poll: poll,
        fnName: fnName,
        matcherRunner: matcherRunner
    )
}

extension SyncExpectation {
    // MARK: - With Synchronous Matchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toMatch,
            to: "to eventually",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventually") { @MainActor in
                        try matcher.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toNotMatch,
            to: "to eventually not",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toNotMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventuallyNot") { @MainActor in
                        try matcher.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toNotMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") { @MainActor in
                        try matcher.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") { @MainActor in
                        try matcher.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    // MARK: - With AsyncMatchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toMatch,
            to: "to eventually",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventually") { @MainActor in
                        try await matcher.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toNotMatch,
            to: "to eventually not",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toNotMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventuallyNot") { @MainActor in
                        try await matcher.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toNotMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") { @MainActor in
                        try await matcher.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") { @MainActor in
                        try await matcher.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }
}

extension AsyncExpectation {
    // MARK: - With Synchronous Matchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toMatch,
            to: "to eventually",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventually") {
                        try matcher.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toNotMatch,
            to: "to eventually not",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toNotMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventuallyNot") {
                        try matcher.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toNotMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") {
                        try matcher.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") {
                        try matcher.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    // MARK: - With AsyncMatchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toMatch,
            to: "to eventually",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventually") {
                        try await matcher.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toNotMatch,
            to: "to eventually not",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toNotMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventuallyNot") {
                        try await matcher.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toNotMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") {
                        try await matcher.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") {
                        try await matcher.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }
}

#endif // #if !os(WASI)
